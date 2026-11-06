# frozen_string_literal: true

require 'base64'
require 'json'
require 'rest-client'
require 'rexml/document'

module Opennms
  module Cookbook
    module Collection
      # On OpenNMS 36 the datacollection configuration (profiles, collection
      # sources and their mib groups, resource types and system definitions)
      # is stored in the database and managed via the v2 REST API
      # (/opennms/api/v2/datacollectionconf) instead of the files under
      # $OPENNMS_HOME/etc/datacollection. The package ships the group files
      # as its on-disk record in $OPENNMS_HOME/etc_archive/datacollection,
      # which is also where this cookbook stages the group files it manages.
      #
      # All datacollection resources (opennms_snmp_collection,
      # opennms_snmp_collection_group, the group path of
      # opennms_resource_type and opennms_system_def) mutate one shared
      # in-run copy of the downloaded documents that lives in the run state;
      # a single delayed multipart upload (POST /datacollectionconf/upload)
      # sends the documents that actually changed at the end of the converge
      # phase. Whole-source and whole-profile deletions use the granular
      # DELETE endpoints because the upload only upserts.
      #
      # Server-side semantics that shape the in-run bookkeeping:
      #
      # * Sources are keyed by the @name attribute of their content (the
      #   canonical name, e.g. "MIB2"); uploading a source fully replaces
      #   its child elements.
      # * An include-collection with a non-empty exclude-filter is
      #   materialized into a synthetic __inline_<profile> source on
      #   upload; the config then holds a plain reference to that source.
      #   The declared form of such includes is not persisted, so profiles
      #   containing them are re-uploaded on every converge (the resulting
      #   server state is identical). An include with a systemDef but no
      #   filter is written as a plain reference: the v2 API does not
      #   persist the restriction.
      # * The source of a filtered include (its materialization target)
      #   must be part of the upload batch or the include silently
      #   degrades to a plain reference, so such sources are included in
      #   the batch even when they are otherwise unchanged.
      # * A batch that creates a new source needs the datacollection-config
      #   document (or profileNames values) in the same batch; since
      #   attachments always go through the config's include-collections,
      #   the config document is included whenever a new source is in the
      #   batch.
      module DatacollectionV36
        UPLOAD_BOUNDARY = 'opennms-datacollection-xml-upload'
        INLINE_SOURCE_PREFIX = '__inline_'
        CONFIG_FILE_NAME = 'datacollection-config.xml'
        DATA_COLLECTION_GROUP_XSD = 'http://xmlns.opennms.org/xsd/config/datacollection'
        # The rrd/rra defaults of a created profile: the datacollection
        # schema requires at least one rra inside rrd, and a profile with
        # an empty rrd permanently breaks the server's config download
        # (XSD validation on marshal)
        DEFAULT_RRAS = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'].freeze

        # Multipart body of POST /datacollectionconf/upload: one file part
        # per document, all named "upload". The part carrying the
        # datacollection-config document is recognized by its root element,
        # the remaining parts are datacollection-group sources keyed by the
        # @name attribute of their content
        def self.upload_body(parts)
          boundary = UPLOAD_BOUNDARY
          body = +''
          parts.each do |filename, xml|
            body << "--#{boundary}\r\n"
            body << "Content-Disposition: form-data; name=\"upload\"; filename=\"#{filename}\"\r\n"
            body << "Content-Type: application/xml\r\n"
            body << "\r\n"
            body << "#{xml}\r\n"
          end
          body << "--#{boundary}--\r\n"
          body
        end

        # Alphanumeric normalization used to match group names against
        # canonical source names ("netsnmp" matches "Net-SNMP", "wmi"
        # matches "WMI")
        def self.alnum(name)
          name.to_s.downcase.gsub(/[^a-z0-9]/, '')
        end

        # Parameters in the SnmpCollectionUtils format (a hash of string
        # pairs or an array of single key/value hashes) as key/value pairs
        def self.params_pairs(params)
          case params
          when Hash
            params.map { |k, v| [k.to_s, v.to_s] }
          when Array
            params.map { |h| [h.keys.first.to_s, h.values.first.to_s] }
          else
            []
          end
        end
      end

      # The v36 datacollection resource support: shared in-run state, name
      # resolution, element mutation and the delayed upload
      module DatacollectionV36Template
        def datacollection_v36?
          node['opennms']['version'].to_i >= 36
        end

        # The accumulated datacollection-config document for this run: a
        # single download mutated in place and shared by all resources, so
        # mutations made by earlier resources are visible to later ones
        def dc_v36_config
          dc_v36_state['config_doc']
        end

        # The pristine, REXML-normalized download, kept for the dirty check:
        # a run whose mutations net out to no change uploads nothing
        def dc_v36_config_original
          dc_v36_state['config_original']
        end

        # The profile (snmp-collection) with the given name in the
        # accumulated config, or nil
        def dc_v36_profile(name)
          dc_v36_config.root.each_element('snmp-collection') do |c|
            return c if c.attributes['name'] == name
          end
          nil
        end

        # The profile row (attributes) with the given name from the server,
        # or nil. Includes disabled profiles, which the config download
        # does not list
        def dc_v36_profile_row(name)
          dc_v36_profiles.find { |p| p['name'] == name }
        end

        # The profile's source references as include-collection hashes in
        # the current-value form: plain canonical names, with a declared
        # name (case-insensitively matching) substituted so that a
        # case-only difference in the declaration does not count as a
        # change. Materialized references (__inline_<profile>) are
        # returned as-is; the declared form of those includes is not
        # persisted by the server
        def dc_v36_profile_includes(name, declared = nil)
          row = dc_v36_profile_row(name)
          return if row.nil?
          names = dc_v36_row_array(row, 'sourceNames')
          names.map do |n|
            group = n
            unless declared.nil?
              match = declared.find { |d| d[:data_collection_group].to_s.casecmp(n) == 0 }
              group = match[:data_collection_group] unless match.nil?
            end
            { data_collection_group: group }
          end
        end

        # The form in which a group is attached to a profile: :plain when
        # the profile holds a plain include-collection reference matching
        # the canonical source name case-insensitively, :inline when the
        # group's materialized form is present (a __inline_<profile>
        # reference, the group identified by the file's @name matching the
        # group name, with any declared systemDef present in the inline
        # content), or nil when the group is not attached
        def dc_v36_group_attach_form(profile_name, group_name, file_at_name: nil, system_def: nil)
          p = dc_v36_profile(profile_name)
          return if p.nil?
          inline_name = "#{DatacollectionV36::INLINE_SOURCE_PREFIX}#{profile_name}"
          canonical = dc_v36_resolve_source(group_name, file_at_name)
          canonical = group_name if canonical.nil?
          p.each_element('include-collection') do |ic|
            ref = ic.attributes['dataCollectionGroup'].to_s
            return :plain if ref.casecmp(canonical) == 0
          end
          return unless p.elements["include-collection[@dataCollectionGroup = '#{inline_name}']"]
          return if file_at_name.nil? || file_at_name.casecmp(group_name) != 0
          unless system_def.nil?
            return if dc_v36_source_id(inline_name).nil?
            sds = []
            inline = dc_v36_source_load(inline_name)
            inline['doc'].root.each_element('systemDef') { |sd| sds << sd.attributes['name'] } unless inline.nil?
            return unless sds.include?(system_def)
          end
          :inline
        end

        # Whether a group is attached to a profile in any form
        def dc_v36_group_attached?(profile_name, group_name, file_at_name: nil, system_def: nil)
          !dc_v36_group_attach_form(profile_name, group_name, file_at_name: file_at_name, system_def: system_def).nil?
        end

        # The canonical source name for a group: an existing source
        # (resolved from the group name or the file stem), else the @name
        # of the group file deployed on disk, else the group name (a new
        # group takes its group name as source name)
        def dc_v36_group_canonical(group_name, file = nil)
          stem = if file.nil?
                   nil
                 elsif file.end_with?('.xml')
                   file[0...file.rindex('.xml')]
                 else
                   file
                 end
          resolved = dc_v36_resolve_source(group_name, stem)
          return resolved unless resolved.nil?
          at_name = dc_v36_file_at_name(file)
          return at_name unless at_name.nil?
          group_name
        end

        # The @name attribute of a group file deployed under
        # $OPENNMS_HOME/etc_archive/datacollection, or nil
        def dc_v36_file_at_name(file)
          return if file.nil?
          path = "#{onms_etc_archive}/datacollection/#{file}"
          return unless ::File.exist?(path)
          doc = REXML::Document.new(::File.read(path))
          doc.root.attributes['name'] unless doc.root.nil?
        rescue StandardError
          nil
        end

        # The canonical source name for a datacollection-group file name
        # (system definitions live in sources, the file name only
        # identifies which one): the file stem resolved against the
        # existing sources, else the @name of the file on disk, else the
        # stem (a new source is named after the file stem)
        def dc_v36_source_for_file(file_name)
          stem = if file_name.end_with?('.xml')
                   file_name[0...file_name.rindex('.xml')]
                 else
                   file_name
                 end
          resolved = dc_v36_resolve_source(stem)
          return resolved unless resolved.nil?
          at_name = dc_v36_file_at_name(file_name)
          return at_name unless at_name.nil?
          stem
        end

        # The accumulated datacollection-group document for a source: an
        # existing source is downloaded once per run and mutated in place;
        # a new source starts as an empty group and is tracked as created
        def dc_v36_source(name)
          state = dc_v36_state
          entry = state['sources'][name]
          return entry unless entry.nil?
          entry = dc_v36_source_load(name)
          return entry unless entry.nil?
          doc = REXML::Document.new
          root = doc.add_element('datacollection-group')
          root.add_attribute('xmlns', DatacollectionV36::DATA_COLLECTION_GROUP_XSD)
          root.add_attribute('name', name)
          state['created'].push(name) unless state['created'].include?(name)
          entry = { 'doc' => doc, 'original' => nil, 'id' => nil, 'created' => true }
          state['sources'][name] = entry
          entry
        end

        # The in-run entry for a source that is already loaded or exists on
        # the server; unlike dc_v36_source this never creates a new source,
        # so it is safe for lookups during load_current_value
        def dc_v36_source_load(name)
          state = dc_v36_state
          entry = state['sources'][name]
          return entry unless entry.nil?
          id = dc_v36_source_id(name)
          return if id.nil?
          xml = dc_v36_get("/datacollectionconf/collectsources/#{id}/download?format=xml")
          entry = { 'doc' => REXML::Document.new(xml), 'original' => REXML::Document.new(xml).to_s, 'id' => id, 'created' => false }
          state['sources'][name] = entry
          entry
        end

        # Record that a source's content must be (re-)synced with the group
        # file at upload time: the group file is declared by the group
        # resource during the action but only converges at the end of the
        # converge phase, so it cannot be read during the action
        def dc_v36_source_file_seed(source_name, file)
          return source_name if file.nil?
          state = dc_v36_state
          state['file_seeds'][source_name] = file
          dc_v36_touch_source(source_name)
          source_name
        end

        # Record a mutation on a source so it can be replayed when the
        # source's document is replaced by its file seed at upload time
        def dc_v36_record_op(source_name, op)
          state = dc_v36_state
          ops = state['source_ops'][source_name] ||= []
          ops.push(op)
        end

        # Rename a source's in-run bookkeeping to the authoritative @name of
        # its uploaded content (the @name can only be known once the group
        # file has converged at the end of the run): the plain
        # include-collection references written under the in-run name are
        # rewritten, since the server stores them raw
        def dc_v36_rename_source(old_name, new_name)
          state = dc_v36_state
          state['sources'][new_name] = state['sources'].delete(old_name)
          state['created'].map! { |n| n == old_name ? new_name : n }
          state['dirty'].map! { |n| n == old_name ? new_name : n }
          if state['source_ops'].key?(old_name)
            state['source_ops'][new_name] = state['source_ops'].delete(old_name)
          end
          dc_v36_config.root.each_element('snmp-collection/include-collection') do |ic|
            if ic.attributes['dataCollectionGroup'] == old_name
              ic.attributes['dataCollectionGroup'] = new_name
            end
          end
        end

        # Resolve the file seeds recorded by the group resources. This runs
        # at the start of the upload, i.e. after the group file resources
        # have converged: a new source is seeded from the file; an existing
        # source takes the file's content when the file differs from the
        # pristine download (the deployed file changed since the last
        # sync). In-run mutations recorded on a source whose document is
        # replaced are replayed on the file's content
        def dc_v36_seed_sources_from_files
          state = dc_v36_state
          state['file_seeds'].each do |seeded_name, file|
            next if state['deleted'].include?(seeded_name)
            path = "#{onms_etc_archive}/datacollection/#{file}"
            next unless ::File.exist?(path)
            xml = ::File.read(path)
            doc = REXML::Document.new(xml)
            at_name = doc.root.attributes['name'] unless doc.root.nil?
            canonical = at_name.nil? ? seeded_name : at_name
            dc_v36_rename_source(seeded_name, canonical) if canonical != seeded_name
            entry = state['sources'][canonical]
            if entry.nil?
              # a new source: seed it with the file content
              entry = { 'doc' => doc, 'original' => doc.to_s, 'id' => nil, 'created' => true }
              state['sources'][canonical] = entry
              state['created'].push(canonical) unless state['created'].include?(canonical)
              (state['source_ops'][canonical] || []).each(&:call)
            elsif entry['original'].nil? || doc.to_s != entry['original']
              entry['doc'] = doc
              entry['original'] = doc.to_s
              (state['source_ops'][canonical] || []).each(&:call)
            end
            state['source_ops'].delete(canonical)
          end
          state['file_seeds'].clear
        end

        # Remove a source from the server (the upload only upserts) and from
        # the in-run documents: plain include-collection references to it
        # are removed from all profiles so a later config upload in the
        # same run cannot resurrect them
        def dc_v36_source_delete(source_name)
          state = dc_v36_state
          id = dc_v36_source_id(source_name)
          unless id
            # the names-and-ids list is cached for the run, so a source that
            # was materialized by the server in this run (an
            # __inline_<profile> from an earlier upload) is not in it;
            # re-fetch once
            state['source_names'] = nil
            id = dc_v36_source_id(source_name)
          end
          unless id.nil?
            begin
              RestClient.delete("#{restv2url}/datacollectionconf/collectsources?id=#{id}", dc_v36_api_headers)
            rescue RestClient::ExceptionWithResponse => e
              # the names-and-ids list is cached for the run, so the source
              # may already have been removed earlier in this run
              raise unless e.http_code == 404
            end
          end
          state['deleted'].push(source_name) unless state['deleted'].include?(source_name)
          state['sources'].delete(source_name)
          state['created'].delete(source_name)
          removed = false
          dc_v36_config.root.each_element('snmp-collection') do |c|
            to_remove = []
            c.each_element('include-collection') do |ic|
              to_remove << ic if ic.attributes['dataCollectionGroup'].to_s.casecmp(source_name) == 0
            end
            to_remove.each do |ic|
              c.delete_element(ic)
              removed = true
            end
          end
          dc_v36_touch_config if removed
        end

        # A resourceType in a source (an already-loaded or existing source
        # only; no new source is created): nil when the source or the
        # resourceType does not exist
        def dc_v36_resource_type(source_name, type_name)
          entry = dc_v36_source_load(source_name)
          return if entry.nil?
          Opennms::Cookbook::Collection::SnmpCollectionUtils
            .resource_types(entry['doc'].root)
            .find { |rt| rt[:name].eql?(type_name) }
        end

        # Add or replace a resourceType in a source; rt in the
        # SnmpCollectionUtils::resource_types hash format. Returns the
        # canonical source name
        def dc_v36_resource_type_set(source_name, rt)
          dc_v36_resource_type_set_apply(source_name, rt)
          dc_v36_record_op(source_name, proc { dc_v36_resource_type_set_apply(source_name, rt) })
          dc_v36_touch_source(source_name)
          source_name
        end

        def dc_v36_resource_type_set_apply(source_name, rt)
          root = dc_v36_source(source_name)['doc'].root
          old = nil
          root.each_element('resourceType') do |el|
            old = el if el.attributes['name'] == rt[:name]
          end
          root.delete_element(old) unless old.nil?
          el = root.add_element('resourceType')
          el.add_attribute('name', rt[:name])
          el.add_attribute('label', rt[:label]) unless rt[:label].nil?
          el.add_attribute('resourceLabel', rt[:resource_label]) unless rt[:resource_label].nil?
          pss = el.add_element('persistenceSelectorStrategy')
          pss.add_attribute('class', rt.dig(:persistence_selector_strategy, :class) || 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy')
          DatacollectionV36.params_pairs(rt.dig(:persistence_selector_strategy, :parameters)).each do |k, v|
            p = pss.add_element('parameter')
            p.add_attribute('key', k)
            p.add_attribute('value', v)
          end
          ss = el.add_element('storageStrategy')
          ss.add_attribute('class', rt.dig(:storage_strategy, :class) || 'org.opennms.netmgt.collection.support.IndexStorageStrategy')
          DatacollectionV36.params_pairs(rt.dig(:storage_strategy, :parameters)).each do |k, v|
            p = ss.add_element('parameter')
            p.add_attribute('key', k)
            p.add_attribute('value', v)
          end
        end

        # Remove a resourceType from a source. Returns the canonical source
        # name
        def dc_v36_resource_type_delete(source_name, type_name)
          dc_v36_resource_type_delete_apply(source_name, type_name)
          dc_v36_record_op(source_name, proc { dc_v36_resource_type_delete_apply(source_name, type_name) })
          dc_v36_touch_source(source_name)
          source_name
        end

        def dc_v36_resource_type_delete_apply(source_name, type_name)
          root = dc_v36_source(source_name)['doc'].root
          root.elements.each('resourceType') do |el|
            next unless el.attributes['name'] == type_name
            root.delete_element(el)
          end
        end

        # A systemDef in a source (an already-loaded or existing source
        # only; no new source is created): nil when the source or the
        # systemDef does not exist
        def dc_v36_system_def(source_name, system_name)
          entry = dc_v36_source_load(source_name)
          return if entry.nil?
          Opennms::Cookbook::Collection::SnmpCollectionUtils
            .system_defs(entry['doc'].root, 'systemDef')
            .find { |sd| sd[:name].eql?(system_name) }
        end

        # Add or replace a systemDef in a source; sd in the
        # SnmpCollectionUtils::system_defs hash format. Returns the
        # canonical source name
        def dc_v36_system_def_set(source_name, sd)
          dc_v36_system_def_set_apply(source_name, sd)
          dc_v36_record_op(source_name, proc { dc_v36_system_def_set_apply(source_name, sd) })
          dc_v36_touch_source(source_name)
          source_name
        end

        def dc_v36_system_def_set_apply(source_name, sd)
          root = dc_v36_source(source_name)['doc'].root
          old = nil
          root.each_element('systemDef') do |el|
            old = el if el.attributes['name'] == sd[:name]
          end
          root.delete_element(old) unless old.nil?
          el = root.add_element('systemDef')
          el.add_attribute('name', sd[:name])
          if !sd[:sysoid].nil?
            e = el.add_element('sysoid')
            e.add_text(sd[:sysoid])
          elsif !sd[:sysoid_mask].nil?
            e = el.add_element('sysoidMask')
            e.add_text(sd[:sysoid_mask])
          end
          if !sd[:ip_addrs].nil? || !sd[:ip_addr_masks].nil?
            list = el.add_element('ipList')
            (sd[:ip_addrs] || []).each do |ip|
              e = list.add_element('ipAddr')
              e.add_text(ip)
            end
            (sd[:ip_addr_masks] || []).each do |ipm|
              e = list.add_element('ipAddrMask')
              e.add_text(ipm)
            end
          end
          unless sd[:include_groups].nil?
            collect = el.add_element('collect')
            sd[:include_groups].each do |ig|
              e = collect.add_element('includeGroup')
              e.add_text(ig)
            end
          end
        end

        # Update an existing systemDef in a source; nil attributes are left
        # untouched, include_groups replaces the collect/includeGroup set
        def dc_v36_system_def_update(source_name, system_name, sysoid: nil, sysoid_mask: nil, ip_addrs: nil, ip_addr_masks: nil, include_groups: nil)
          dc_v36_system_def_update_apply(source_name, system_name, sysoid: sysoid, sysoid_mask: sysoid_mask, ip_addrs: ip_addrs, ip_addr_masks: ip_addr_masks, include_groups: include_groups)
          dc_v36_record_op(source_name, proc { dc_v36_system_def_update_apply(source_name, system_name, sysoid: sysoid, sysoid_mask: sysoid_mask, ip_addrs: ip_addrs, ip_addr_masks: ip_addr_masks, include_groups: include_groups) })
          dc_v36_touch_source(source_name)
        end

        def dc_v36_system_def_update_apply(source_name, system_name, sysoid: nil, sysoid_mask: nil, ip_addrs: nil, ip_addr_masks: nil, include_groups: nil)
          root = dc_v36_source(source_name)['doc'].root
          el = nil
          root.each_element('systemDef') do |sd_el|
            el = sd_el if sd_el.attributes['name'] == system_name
          end
          return if el.nil?
          unless sysoid.nil?
            e = el.elements['sysoid']
            e = el.add_element('sysoid') if e.nil?
            e.text = sysoid
            el.delete_element('sysoidMask')
          end
          unless sysoid_mask.nil?
            e = el.elements['sysoidMask']
            e = el.add_element('sysoidMask') if e.nil?
            e.text = sysoid_mask
            el.delete_element('sysoid')
          end
          unless ip_addrs.nil?
            list = el.elements['ipList']
            list = el.add_element('ipList') if list.nil?
            dc_v36_remove_child_elements(list, 'ipAddr')
            ip_addrs.each do |ip|
              e = list.add_element('ipAddr')
              e.add_text(ip)
            end
          end
          unless ip_addr_masks.nil?
            list = el.elements['ipList']
            list = el.add_element('ipList') if list.nil?
            dc_v36_remove_child_elements(list, 'ipAddrMask')
            ip_addr_masks.each do |ipm|
              e = list.add_element('ipAddrMask')
              e.add_text(ipm)
            end
          end
          unless include_groups.nil?
            collect = el.elements['collect']
            collect = el.add_element('collect') if collect.nil?
            dc_v36_remove_child_elements(collect, 'includeGroup')
            include_groups.each do |ig|
              e = collect.add_element('includeGroup')
              e.add_text(ig)
            end
          end
        end

        # Remove a systemDef from a source. Returns the canonical source
        # name
        def dc_v36_system_def_delete(source_name, system_name)
          dc_v36_system_def_delete_apply(source_name, system_name)
          dc_v36_record_op(source_name, proc { dc_v36_system_def_delete_apply(source_name, system_name) })
          dc_v36_touch_source(source_name)
          source_name
        end

        def dc_v36_system_def_delete_apply(source_name, system_name)
          root = dc_v36_source(source_name)['doc'].root
          root.elements.each('systemDef') do |el|
            next unless el.attributes['name'] == system_name
            root.delete_element(el)
          end
        end

        # Add the profile element to the accumulated config (create a
        # profile). Returns the element
        def dc_v36_profile_create(name, rrd_step:, rras:, max_vars_per_pdu:, snmp_stor_flag:, include_collections:)
          # the schema requires at least one rra inside rrd: an empty rrd
          # permanently breaks the server's config download, so an
          # explicitly empty declaration is rejected and an undeclared one
          # takes the OpenNMS defaults (as on pre-36 creates)
          raise Chef::Exceptions::ValidationFailed, 'snmp_collection `rras` must not be an empty array' unless rras.nil? || !rras.empty?
          rras = rras.nil? ? DatacollectionV36::DEFAULT_RRAS : rras
          el = dc_v36_config.root.add_element('snmp-collection', 'name' => name, 'snmpStorageFlag' => snmp_stor_flag || 'select')
          el.add_attribute('maxVarsPerPdu', max_vars_per_pdu.to_s) unless max_vars_per_pdu.nil?
          rrd = el.add_element('rrd', 'step' => (rrd_step || 300).to_s)
          (rras || []).each do |rra|
            r = rrd.add_element('rra')
            r.add_text(rra)
          end
          (include_collections || []).each { |ic| dc_v36_add_include_element(el, ic) }
          dc_v36_touch_config
          el
        end

        # Update the profile element in the accumulated config; nil
        # attributes are left untouched, include_collections (when given)
        # replaces all of the profile's includes. Returns the element
        def dc_v36_profile_update(name, rrd_step: nil, rras: nil, max_vars_per_pdu: nil, snmp_stor_flag: nil, include_collections: nil)
          p = dc_v36_profile(name)
          raise Chef::Exceptions::CurrentValueDoesNotExist, "Collection '#{name}' not found." if p.nil?
          rrd = p.elements['rrd']
          unless rrd_step.nil?
            rrd = p.add_element('rrd') if rrd.nil?
            rrd.attributes['step'] = rrd_step.to_s
          end
          raise Chef::Exceptions::ValidationFailed, 'snmp_collection `rras` must not be an empty array' unless rras.nil? || !rras.empty?
          unless rras.nil?
            rrd = p.add_element('rrd') if rrd.nil?
            dc_v36_remove_child_elements(rrd, 'rra')
            rras.each do |rra|
              r = rrd.add_element('rra')
              r.add_text(rra)
            end
          end
          p.attributes['snmpStorageFlag'] = snmp_stor_flag unless snmp_stor_flag.nil?
          p.attributes['maxVarsPerPdu'] = max_vars_per_pdu.to_s unless max_vars_per_pdu.nil?
          unless include_collections.nil?
            dc_v36_remove_child_elements(p, 'include-collection')
            include_collections.each { |ic| dc_v36_add_include_element(p, ic) }
          end
          dc_v36_touch_config
          p
        end

        # Add or replace a single include-collection for a group in a
        # profile; `include` in the include_collections hash form and
        # `group_canonical` the canonical source name the reference is
        # written under. Replaces an existing plain reference to the group;
        # with replace_inline, also the profile's __inline_<profile>
        # reference (the group's materialized form)
        def dc_v36_group_include_set(profile_name, group_canonical, include, replace_inline: false)
          p = dc_v36_profile(profile_name)
          raise Chef::Exceptions::ResourceNotFound, "Collection '#{profile_name}' not found." if p.nil?
          inline_name = "#{DatacollectionV36::INLINE_SOURCE_PREFIX}#{profile_name}"
          to_remove = []
          p.each_element('include-collection') do |ic|
            ref = ic.attributes['dataCollectionGroup'].to_s
            if ref.casecmp(group_canonical) == 0 || (replace_inline && ref == inline_name)
              to_remove << ic
            end
          end
          to_remove.each { |ic| p.delete_element(ic) }
          dc_v36_add_include_element(p, include)
          dc_v36_touch_config
          p
        end

        # Remove the include-collection(s) for a group from a profile: the
        # plain reference to the canonical name and, with remove_inline,
        # the profile's __inline_<profile> reference (the group's
        # materialized form)
        def dc_v36_group_include_remove(profile_name, group_canonical, remove_inline: false)
          p = dc_v36_profile(profile_name)
          return false if p.nil?
          inline_name = "#{DatacollectionV36::INLINE_SOURCE_PREFIX}#{profile_name}"
          to_remove = []
          p.each_element('include-collection') do |ic|
            ref = ic.attributes['dataCollectionGroup'].to_s
            to_remove << ic if ref.casecmp(group_canonical) == 0 || (remove_inline && ref == inline_name)
          end
          to_remove.each { |ic| p.delete_element(ic) }
          dc_v36_touch_config unless to_remove.empty?
          !to_remove.empty?
        end

        # Attach a source to a profile with a plain include-collection when
        # the profile does not reference the source yet. A materialized
        # reference (__inline_<profile>) is left in place: the source is
        # already contributing to the profile via its inline content
        def dc_v36_profile_attach(profile_name, source_name)
          p = dc_v36_profile(profile_name)
          raise Chef::Exceptions::ResourceNotFound, "Collection '#{profile_name}' not found." if p.nil?
          p.each_element('include-collection') do |ic|
            return p if ic.attributes['dataCollectionGroup'].to_s.casecmp(source_name) == 0
          end
          dc_v36_add_include_element(p, { data_collection_group: source_name })
          dc_v36_touch_config
          p
        end

        # Delete a profile from the accumulated config and from the server
        # (the upload only upserts). The synthetic __inline_<name> source
        # is removed as well, since the server does not clean it up when a
        # profile stops producing inline content
        def dc_v36_profile_delete(name)
          deleted = false
          p = dc_v36_profile(name)
          unless p.nil?
            dc_v36_config.root.delete_element(p)
            dc_v36_touch_config
            deleted = true
          end
          row = dc_v36_profile_row(name)
          unless row.nil?
            begin
              # RestClient.delete does not send a request body, so use
              # Request.execute: the endpoint requires the ids as a JSON
              # array body
              response = RestClient::Request.execute(
                method: :delete,
                url: "#{restv2url}/datacollectionconf/profiles",
                payload: [row['id']].to_json,
                headers: dc_v36_api_headers.merge('Content-Type' => 'application/json')
              )
              raise "OpenNMS datacollection profile delete failed: #{response.code}" unless [200, 204].include?(response.code)
            rescue RestClient::ExceptionWithResponse => e
              # the profile list is cached for the run, so the profile may
              # already have been removed earlier in this run
              raise unless e.http_code == 404
            end
            deleted = true
          end
          dc_v36_source_delete("#{DatacollectionV36::INLINE_SOURCE_PREFIX}#{name}")
          deleted
        end

        # Remove the synthetic __inline_<profile> source from the server
        # when the profile no longer references it and no remaining include
        # would materialize one: the server keeps the old inline source
        # around when a profile stops producing inline content
        def dc_v36_cleanup_inline_source(profile_name)
          p = dc_v36_profile(profile_name)
          return if p.nil?
          inline_name = "#{DatacollectionV36::INLINE_SOURCE_PREFIX}#{profile_name}"
          referenced = false
          filtered = false
          p.each_element('include-collection') do |ic|
            referenced = true if ic.attributes['dataCollectionGroup'] == inline_name
            ic.each_element('exclude-filter') do
              filtered = true
              break
            end
          end
          return if referenced || filtered
          dc_v36_source_delete(inline_name)
        end

        # The actual upload; called by the delayed 'datacollection config
        # upload' ruby_block, i.e. after all file resources (group files)
        # have converged
        def dc_v36_upload_execute
          state = dc_v36_state
          dc_v36_seed_sources_from_files
          targets = dc_v36_materialization_targets
          parts = []
          (state['dirty'] + state['created'] + targets).uniq.each do |name|
            next if 'config'.eql?(name)
            next if state['deleted'].include?(name)
            entry = state['sources'][name] || dc_v36_source_load(name)
            # a materialization target that does not exist is left out of
            # the batch: the server keeps the plain reference and warns
            next if entry.nil?
            # an existing source that did not actually change only needs
            # to be in the batch as a materialization target; a created
            # source always needs to be uploaded, even when its content
            # equals what was seeded from the file
            next if !entry['created'] && entry['original'] && entry['doc'].to_s == entry['original'] && !targets.include?(name)
            parts << ["#{name}.xml", entry['doc'].to_s]
          end
          new_source_in_batch = parts.any? { |filename, _xml| state['created'].include?(filename.sub(/\.xml$/, '')) }
          if state['dirty'].include?('config') || new_source_in_batch
            parts.unshift([DatacollectionV36::CONFIG_FILE_NAME, state['config_doc'].to_s])
          end
          return if parts.empty?

          Chef::Log.debug("opennms datacollection upload: #{parts.map(&:first).join(', ')}")
          begin
            response = RestClient.post(
              "#{restv2url}/datacollectionconf/upload",
              DatacollectionV36.upload_body(parts),
              dc_v36_api_headers.merge('Content-Type' => "multipart/form-data; boundary=#{DatacollectionV36::UPLOAD_BOUNDARY}")
            )
          rescue RestClient::ExceptionWithResponse => e
            raise "OpenNMS datacollection upload failed: #{e.response}"
          end
          result = JSON.parse(response.body)
          errors = result['errors']
          unless errors.nil? || errors.empty?
            raise "OpenNMS datacollection upload failed: #{errors.map { |err| err['error'] || err.to_s }.join('; ')}"
          end
        end

        private

        def dc_v36_state
          node.run_state['opennms_datacollection_v36'] ||= begin
            xml = dc_v36_get('/datacollectionconf/config/download?format=xml')
            {
              'config_doc' => REXML::Document.new(xml),
              'config_original' => REXML::Document.new(xml).to_s,
              'source_names' => nil,
              'profiles' => nil,
              'sources' => {},
              'dirty' => [],
              'created' => [],
              'deleted' => [],
              'file_seeds' => {},
              'source_ops' => {},
            }
          end
        end

        def dc_v36_api_headers
          { 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" }
        end

        def dc_v36_get(path)
          RestClient.get("#{restv2url}#{path}", dc_v36_api_headers.merge('Accept-Encoding' => 'identity')).body
        end

        # An array field of a profile row (sourceNames, rrdRras): the v2 API
        # serves it as a JSON array, but a JSON string is tolerated as well
        def dc_v36_row_array(row, key)
          value = row[key]
          return [] if value.nil?
          value.is_a?(String) ? JSON.parse(value) : value
        end

        # The name/id pairs of all collection sources, cached for the run
        def dc_v36_source_names
          dc_v36_state['source_names'] ||= JSON.parse(dc_v36_get('/datacollectionconf/collectsources/names-and-ids'))
        end

        def dc_v36_source_id(name)
          entry = dc_v36_source_names.find { |s| s['name'] == name }
          entry.nil? ? nil : entry['id']
        end

        def dc_v36_profiles
          dc_v36_state['profiles'] ||= JSON.parse(dc_v36_get('/datacollectionconf/profiles'))
        end

        # Resolve a group name (or file stem) to the canonical name of an
        # existing collection source: exact, then case-insensitive, then
        # alphanumeric-normalized (only on a unique match). Returns nil
        # when nothing matches (the group is new)
        def dc_v36_resolve_source(*candidates)
          names = dc_v36_source_names.map { |s| s['name'] }
          candidates.each do |c|
            next if c.nil?
            match = names.find { |n| n == c }
            return match unless match.nil?
          end
          candidates.each do |c|
            next if c.nil?
            match = names.find { |n| n.casecmp(c) == 0 }
            return match unless match.nil?
          end
          candidates.each do |c|
            next if c.nil?
            alnum = DatacollectionV36.alnum(c)
            next if alnum.empty?
            matches = names.select { |n| DatacollectionV36.alnum(n) == alnum }
            return matches.first if matches.one?
          end
          nil
        end

        def dc_v36_touch_config
          dc_v36_touch('config')
        end

        def dc_v36_touch_source(name)
          dc_v36_touch(name)
        end

        def dc_v36_touch(key)
          state = dc_v36_state
          state['dirty'].push(key) unless state['dirty'].include?(key)
          dc_v36_upload_resource_ensure
        end

        # The include-collection element for a declared include: the
        # group name is resolved to the canonical name of an existing
        # source (the server stores plain references raw), includes with a
        # non-empty exclude-filter are written in the declared form and
        # materialized by the server on upload; every other include is a
        # plain reference. The systemDef attribute is only part of the
        # declared (filtered) form: on a plain reference the server drops
        # it, so an include with a systemDef but no filter restricts
        # nothing and is written as a plain reference (the restriction is
        # not persisted by the v2 API)
        def dc_v36_add_include_element(profile_el, include)
          group = include[:data_collection_group]
          raise Chef::Exceptions::ValidationFailed, 'include_collections entries require :data_collection_group' if group.nil?

          resolved = dc_v36_resolve_source(group)
          group = resolved unless resolved.nil?
          filters = include[:exclude_filters]
          filters = [] if filters.nil?
          el = profile_el.add_element('include-collection', 'dataCollectionGroup' => group)
          system_def = include[:system_def]
          el.add_attribute('systemDef', system_def) unless system_def.nil? || filters.empty?
          filters.each do |f|
            f_el = el.add_element('exclude-filter')
            f_el.add_text(f)
          end
          el
        end

        # The sources the accumulated config needs in the upload batch:
        # the referenced source of every include-collection with a
        # non-empty exclude-filter (the server materializes those includes
        # and warns - keeping a plain reference - when the source is not in
        # the batch)
        def dc_v36_materialization_targets
          targets = []
          dc_v36_config.root.each_element('snmp-collection/include-collection') do |ic|
            group = ic.attributes['dataCollectionGroup']
            next if group.nil?

            has_filter = false
            ic.each_element('exclude-filter') do
              has_filter = true
              break
            end
            targets << group if has_filter && !targets.include?(group)
          end
          targets
        end

        # The delayed end-of-run upload: declared on the first mutation,
        # executed once after all immediate actions, and skipped entirely
        # when the accumulated documents net out to the downloaded state
        # (for example when a create and a delete in the same run cancel
        # each other out)
        def dc_v36_upload_resource_ensure
          return unless find_resource(:ruby_block, 'datacollection config upload').nil?

          r = self
          with_run_context :root do
            declare_resource(:ruby_block, 'datacollection config upload') do
              description 'Upload the accumulated datacollection documents to the OpenNMS 36 v2 API'
              block { r.dc_v36_upload_execute }
              action :nothing
              delayed_action :create
            end
          end
        end

        # REXML's delete_element removes only the first child element
        # matching a name, so collect all matches first and remove them
        # one by one
        def dc_v36_remove_child_elements(parent, name)
          to_remove = []
          parent.each_element(name) { |e| to_remove << e }
          to_remove.each { |e| parent.delete_element(e) }
        end
      end
    end
  end
end
