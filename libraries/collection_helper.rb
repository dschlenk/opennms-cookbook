module Opennms
  module Cookbook
    module Collection
      module SnmpCollectionTemplate
        def snmp_resource_init
          snmp_resource_create unless snmp_resource_exist?
        end

        def snmp_resource
          return unless snmp_resource_exist?
          find_resource!(:template, "#{onms_etc}/datacollection-config.xml")
        end

        private

        def snmp_resource_exist?
          !find_resource(:template, "#{onms_etc}/datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def snmp_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/datacollection-config.xml", 'snmp')
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/datacollection-config.xml") do
              cookbook 'opennms'
              source 'datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections,
                rrd_base_dir: node['opennms']['properties']['dc']['rrd_base_dir'],
                rrd_dc_dir: node['opennms']['properties']['dc']['rrd_dc_dir']
              )
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end

      module XmlCollectionTemplate
        def xml_resource_init
          xml_resource_create unless xml_resource_exist?
        end

        def xml_resource
          return unless xml_resource_exist?
          find_resource!(:template, "#{onms_etc}/xml-datacollection-config.xml")
        end

        def import_groups_resources
          new_resource.import_groups.each do |ig|
            case new_resource.import_groups_source
            when 'cookbook_file'
              declare_resource(:cookbook_file, "#{onms_etc}/xml-datacollection/#{ig}") do
                owner node['opennms']['username']
                group node['opennms']['grouname']
                mode '0644'
                source ig
              end
            when 'external'
              Chef::Log.debug("Not managing XML Group file #{ig} for #{new_resource.url} in collection #{new_resource.collection_name}")
            else
              declare_resource(:remote_file, "#{onms_etc}/xml-datacollection/#{ig}") do
                owner node['opennms']['username']
                group node['opennms']['grouname']
                mode '0644'
                source "#{new_resource.import_groups_source}/#{ig}"
              end
            end
          end
        end

        def delete_import_groups_files
          new_resource.import_groups.each do |ig|
            declare_resource(:file, "#{onms_etc}/xml-datacollection/#{ig}") do
              action :delete
            end
          end unless new_resource.import_groups_source.eql?('external')
        end

        private

        def xml_resource_exist?
          !find_resource(:template, "#{onms_etc}/xml-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def xml_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/xml-datacollection-config.xml", 'xml')

          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/xml-datacollection-config.xml") do
              cookbook 'opennms'
              source 'xml-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(collections: file.collections)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end

      class OpennmsCollectionConfigFile
        include Opennms::XmlHelper
        attr_reader :collections

        def initialize
          @collections = {}
        end

        def read!(file = 'datacollection-config.xml', type)
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

          doc = xmldoc_from_file(file)
          prefix = case type
                   when 'snmp'
                     ''
                   else
                     "#{type}-"
                   end
          doc.each_element("#{prefix}datacollection-config/#{type}-collection") do |c|
            name = c.attributes['name']
            rrd_step = c.elements['rrd/@step'].value.to_i
            rras = []
            c.each_element('rrd/rra') do |rra|
              rras.push xml_element_text(rra)
            end
            @collections[name] = OpennmsCollection.create(name: name, type: type, rrd_step: rrd_step, rras: rras)
            @collections[name].type_config(c)
          end
        end

        def to_s
          @collections.map(&:to_s).join("\n")
        end

        def add(c)
          @collections[c.name] = c
        end

        def remove(c)
          @collections.delete(c.name)
        end

        def include?(c)
          @collections.any? { |c2| c.eql?(c2) }
        end

        def self.read(file = 'datacollection-config.xml', type)
          cf = OpennmsCollectionConfigFile.new
          cf.read!(file, type)
          cf
        end
      end

      module XmlCollectionGroupsTemplate
        def groupsfile_resource_init(file)
          groupsfile_resource_create(file) unless groupsfile_resource_exist?(file)
        end

        def groupsfile_resource(file)
          return unless groupsfile_resource_exist?(file)
          find_resource!(:template, "#{onms_etc}/xml-datacollection/#{file}")
        end

        private

        def groupsfile_resource_exist?(file)
          !find_resource(:template, "#{onms_etc}/xml-datacollection/#{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def groupsfile_resource_create(file)
          groupsfile = Opennms::Cookbook::Collection::OpennmsCollectionXmlGroupsFile.new
          groupsfile.read!("#{onms_etc}/xml-datacollection/#{file}") if ::File.exist?("#{onms_etc}/xml-datacollection/#{file}")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/xml-datacollection/#{file}") do
              cookbook 'opennms'
              source 'xml-groups.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(groupsfile: groupsfile)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end

      class OpennmsCollectionXmlGroupsFile
        include Opennms::XmlHelper
        attr_reader :groups

        def initialize
          @groups = []
        end

        def read!(file = 'datacollection-config.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          @groups = XmlCollection.groups_from_element(doc, '/xml-groups/xml-group') || []
        end

        def to_s
          @groups.map(&:to_s).join("\n")
        end

        def add(g)
          @groups.push = g
        end

        def remove(group)
          @groups.delete_if { |g| g['name'].eql?(group['name']) }
        end

        def group(name:)
          gn = @groups.filter { |g| g['name'].eql?(name) }
          return if gn.nil? || gn.empty?
          raise DuplicateXmlGroup, "More than one group named #{name} found in file" unless gn.one?
          gn.pop
        end

        def self.read(file = 'datacollection-config.xml')
          cf = OpennmsCollectionXmlGroupsFile.new
          cf.read!(file)
          cf
        end
      end

      class OpennmsCollection
        include Opennms::XmlHelper
        attr_reader :name, :rrd_step, :rras, :type

        def initialize(name:, type:, rrd_step: nil, rras: nil)
          @name = name
          @name.freeze
          @type = type
          @type.freeze
          @rrd_step = rrd_step || 300
          @rras = rras || ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
        end

        def to_s
          "name: #{@name}\n" \
            "type: #{@type}\n" \
            "rrd_step: #{@rrd_step}\n" \
            "rras: #{@rras}"
        end

        def eql?(c)
          return false unless self.class.eql?(c.class)
          name.eql?(c.name) && type.eql?(c.type) && rrd_step.eql?(c.rrd_step) && rras.eql?(c.rras)
        end

        def match?(c)
          name.eql?(c.name) && type.eql?(c.type)
        end

        def update(rrd_step: nil, rras: nil)
          @rrd_step = rrd_step unless rrd_step.nil?
          @rras = rras unless rras.nil?
        end

        def type_config(_c)
          raise 'Unimplemented method'
        end

        def self.create(**properties)
          case properties.fetch(:type)
          when 'xml'
            XmlCollection.new(**properties)
          when 'snmp'
            SnmpCollection.new(**properties)
          end
        end
      end

      class SnmpCollection < OpennmsCollection
        attr_reader :include_collections, :resource_types, :groups, :systems, :max_vars_per_pdu, :snmp_stor_flag
        def initialize(name:, type: 'snmp', rrd_step: nil, rras: nil, max_vars_per_pdu: nil, snmp_stor_flag: nil, include_collections: nil, resource_types: nil, groups: nil, systems: nil)
          @include_collections = include_collections || []
          @resource_types = resource_types || []
          @groups = groups || []
          @systems = systems || []
          @max_vars_per_pdu = max_vars_per_pdu
          @snmp_stor_flag = snmp_stor_flag
          super(name: name, type: type, rrd_step: rrd_step, rras: rras)
        end

        def type_config(c)
          @max_vars_per_pdu = begin
                                Integer(c.attributes['maxVarsPerPdu'])
                              rescue
                                nil
                              end
          @snmp_stor_flag = c.attributes['snmpStorageFlag']
          c.each_element('include-collection') do |ic|
            unless ic.elements['exclude-filter'].nil?
              exclude_filters = []
              ic.each_element('exclude-filter') do |ef|
                exclude_filters.push(xml_element_text(ef))
              end
            end
            @include_collections.push({ data_collection_group: ic.attributes['dataCollectionGroup'], exclude_filters: exclude_filters, system_def: ic.attributes['systemDef'] }.compact)
          end
          c.each_element('resourceType') do |rt|
            name = rt.attributes['name']
            label = rt.attributes['label']
            resource_label = rt.attributes['resourceLabel']
            pss_params = {}
            rt.each_element('persistenceSelectorStrategy/parameter') do |rtp|
              pss_params[rtp.attributes['key']] = rtp.attributes['value']
            end
            pss_class = rt.elements['persistenceSelectorStrategy/@class'].value
            ss_params = {}
            rt.each_element('storageStrategy/parameter') do |rtp|
              ss_params[rtp.attributes['key']] = rtp.attributes['value']
            end
            ss_class = rt.elements['storageStrategy/@class'].value
            @resource_types.push({ name: name, label: label, resource_label: resource_label, persistence_selector_strategy: { class: pss_class, parameters: pss_params }, storage_strategy: { class: ss_class, parameters: ss_params } }.compact)
          end
          c.each_element('groups/group') do |g|
            mib_objs = []
            g.each_element('mibObj') do |mo|
              mib_objs.push({ oid: mo.attributes['oid'], instance: mo.attributes['instance'], alias: mo.attributes['alias'], type: mo.attributes['type'], maxval: mo.attributes['maxval'], minval: mo.attributes['minval'] })
            end
            subgroups = []
            g.each_element('includeGroup') do |ig|
              subgroups.push(xml_element_text(ig))
            end
            properties = []
            g.each_element('property') do |p|
              pp = {}
              p.each_element['parameter'] do |ppp|
                pp[ppp.attributes['key']] = ppp.attributes['value']
              end
              properties.push({ instance: p.attributes['instance'], alias: p.attributes['alias'], class_name: p.attributes['class-name'], parameters: pp })
            end
            @groups.push({ name: g.attributes['name'], if_type: g.attributes['ifType'], mib_objs: mib_objs, include_groups: subgroups, properties: properties }.compact)
          end
          c.each_element('systems/systemDef') do |sd|
            @systems.push({ name: sd.attributes['name'],
                            sysoid: xml_element_text(sd.elements['sysoid']),
                            sysoid_mask: xml_element_text(sd.elements['sysoidMask']),
                            ip_addrs: xml_text_array(sd, 'ipList/ipAddr'),
                            ip_addr_masks: xml_text_array(sd, 'ipList/ipAddrMask'),
                            include_groups: xml_text_array(sd, 'collect/includeGroup'),
            }.compact)
          end
        end

        def update(rrd_step:, rras:, max_vars_per_pdu:, snmp_stor_flag:, include_collections:)
          super(rrd_step: rrd_step, rras: rras)
          @include_collections = include_collections unless include_collections.nil?
          @max_vars_per_pdu = max_vars_per_pdu unless max_vars_per_pdu.nil?
          @snmp_stor_flag = snmp_stor_flag unless snmp_stor_flag.nil?
        end

        def include_collection(data_collection_group:)
          groups = @include_collections.select { |ic| ic[:data_collection_group].eql?(data_collection_group) }
          return if groups.nil? || groups.empty?
          raise DuplicateIncludeCollection, "More than one include-collection for dataCollectionGroup named '#{data_collection_group}' found in #{@name}" unless groups.one?
          groups.pop
        end
      end

      class XmlCollection < OpennmsCollection
        attr_reader :sources
        def initialize(name:, type: 'xml', rrd_step: nil, rras: nil)
          @sources = []
          super
        end

        def include?(source)
          @sources.any? { |s| s.eql?(source) }
        end

        def source(url:)
          source = @sources.filter { |s| s.url.eql?(url) }
          return if source.nil? || source.empty?
          raise XmlSourceDuplicateEntry, "Duplicate xml-source entries found for url '#{url}'" unless source.one?
          source.pop
        end

        def type_config(c)
          c.each_element('xml-source') do |s|
            url = s.attributes['url']
            groups = self.class.groups_from_element(s, 'xml-group')
            import_groups = []
            s.each_element('import-groups') do |ig|
              f = xml_element_text(ig)
              if f.start_with?('xml-datacollection/')
                import_groups.push(f[19..-1])
              else
                import_groups.push(f)
              end
            end
            request = nil
            unless s.elements['request'].nil?
              request = {}
              request['method'] = s.elements['request'].attributes['method']
              rps = {}
              s.each_element('request/parameter') do |rp|
                rps[rp.attributes['name']] = rp.attributes['value']
              end
              request['parameters'] = rps
              hs = {}
              s.each_element('request/header') do |h|
                hs[h.attributes['name']] = h.attributes['value']
              end
              request['headers'] = hs
              unless s.elements['request/content'].nil?
                request['content_type'] = xml_attr_value(s, 'request/content/@type')
                request['content'] = xml_element_multiline_text(s, 'request/content')
              end
            end
            sources.push(XmlSource.new(url: url, groups: groups, import_groups: import_groups, request: request))
          end
        end

        def self.groups_from_element(element, xpath)
          return if element.nil? || !element.is_a?(REXML::Element) || element.elements[xpath].nil?
          groups = []
          element.each_element(xpath) do |g|
            rk = [] unless g.elements['resource-key'].nil?
            g.each_element('resource-key/key-xpath') do |k|
              rk.push k.texts.collect(&:value).join('').strip
            end
            xml_objects = []
            g.each_element('xml-object') do |o|
              xml_objects.push({ 'name' => o.attributes['name'], 'type' => o.attributes['type'], 'xpath' => o.attributes['xpath'] })
            end
            xmlgroup = { 'name' => g.attributes['name'], 'resource_type' => g.attributes['resource-type'], 'resource_xpath' => g.attributes['resource-xpath'] }
            xmlgroup['resource_keys'] = rk unless rk.nil?
            xmlgroup['objects'] = xml_objects unless xml_objects.nil?
            xmlgroup['key_xpath'] = g.attributes['key-xpath'] unless g.attributes['key-xpath'].nil?
            xmlgroup['timestamp_xpath'] = g.attributes['timestamp-xpath'] unless g.attributes['timestamp-xpath'].nil?
            xmlgroup['timestamp_format'] = g.attributes['timestamp-format'] unless g.attributes['timestamp-format'].nil?
            groups.push xmlgroup
          end
          groups
        end
      end

      class XmlSource
        attr_reader :url, :groups, :import_groups, :request

        def initialize(url:, groups:, import_groups:, request: nil)
          @url = url
          @groups = groups || []
          @import_groups = import_groups || []
          @request = request
        end

        def to_s
          "url='#{@url}'\n" \
            "groups='#{@groups.collect(&:to_s).join(', ')}'\n" \
            "import_groups='#{@import_groups.collect(&:to_s).join(', ')}'\n" \
            "request='#{@request}'"
        end

        def eql?(s)
          self.class.eql?(s.class) && @url.eql?(s.url) && @groups.eql?(s.groups) && @import_groups.eql?(s.import_groups) && @request.eql?(s.request)
        end

        def match?(s)
          @url.eql?(s.url)
        end

        def group(name:)
          gn = @groups.filter { |g| g['name'].eql?(name) }
          return if gn.nil? || gn.empty?
          raise DuplicateXmlGroup, "More than one group named #{name} found in file" unless gn.one?
          gn.pop
        end

        def update(request_method:, request_headers:, request_params:, request_content:, request_content_type:, import_groups:, groups:)
          @request = self.class.request_from_properties(request_method: request_method, request_params: request_params, request_headers: request_headers, request_content: request_content, request_content_type: request_content_type)
          if false.eql?(import_groups)
            @import_groups = []
          elsif !import_groups.empty?
            @import_groups = import_groups
          end
          if false.eql?(groups)
            @groups = []
          elsif !groups.empty?
            @groups = groups
          end
        end

        def self.request_from_properties(request_method:, request_params:, request_headers:, request_content:, request_content_type:)
          r = nil
          if !request_method.nil? || (!request_params.nil? && !request_params.empty?) || (!request_headers.nil? && !request_headers.empty?) || !request_content.nil? || !request_content_type.nil?
            r = {}
            r['method'] = request_method unless request_method.nil?
            unless request_params.nil? || request_params.empty?
              r['parameters'] = {}
              request_params.each do |k, v|
                r['parameters'][k] = v
              end
            end
            unless request_headers.nil? || request_headers.empty?
              r['headers'] = {}
              request_headers.each do |k, v|
                r['headers'][k] = v
              end
            end
            r['content'] = request_content unless request_content.nil?
            r['content_type'] = request_content_type unless request_content_type.nil?
          end
          r
        end

        def self.create(url:, import_groups:, groups:, request_method:, request_params:, request_headers:, request_content:, request_content_type:)
          XmlSource.new(url: url, groups: groups, import_groups: import_groups, request: request_from_properties(request_method: request_method, request_params: request_params, request_headers: request_headers, request_content: request_content, request_content_type: request_content_type))
        end
      end

      class WsmanCollection < OpennmsCollection
      end

      class JmxCollection < OpennmsCollection
      end

      class JdbcCollection < OpennmsCollection
      end

      class XmlSourceDuplicateEntry < StandardError; end

      class XmlCollectionDoesNotExist < StandardError; end

      class XmlSourceDoesNotExist < StandardError; end

      class DuplicateXmlGroup < StandardError; end

      class DuplicateIncludeCollection < StandardError; end

      class NoSuchCollection < StandardError; end
    end
  end
end
