module Opennms
  module Cookbook
    module ConfigHelpers
      module Event
        module Helper
          def element_text(element, xpath = nil)
            e = if xpath.nil?
                  element
                else
                  element.elements[xpath]
                end
            e.texts.collect(&:value).join('').strip unless e.nil?
          end

          def is_positive_i?(s)
            begin
              Integer(s)
            rescue
              false
            end
          end

          def element_multiline_text(element, xpath)
            element.elements[xpath].texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n") if !element.nil? && !element.elements[xpath].nil?
          end

          def attr_value(element, xpath)
            element.elements[xpath].value if !element.nil? && !element.elements[xpath].nil? && element.elements[xpath].is_a?(REXML::Attribute)
          end
        end

        module EventconfSourceRubyBlock
          require_relative 'rbac'
          include Opennms::Rbac

          def eventconf_source_resource_init(source_name, position)
            unless eventconf_source_resource_exist?(source_name)
              eventconf_source_resource_create(source_name, position)
            end
          end

          def eventconf_source_resource(source_name)
            return unless eventconf_source_resource_exist?
            find_resource!(:ruby_block, block_name(source_name))
          end

          def eventconf_source_exist?(source_name)
            !current_source(source_name).nil?
          end

          def source_name_from_file(file)
            name = file.to_s
            name = name.sub(%r{^events/}, '')
            name.sub(/\.xml$/, '')
          end

          def new_definition(source_name, source_type, source, source_properties, variables)
            tempfile = "#{Chef::Config[:file_cache_path]}/#{source_name}.xml"
            case source_type
            when 'cookbook_file'
              cookbook_file tempfile do
                sensitive true
                source source
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '664'
                source_properties.each do |k, v|
                  send(k, v)
                end unless source_properties.nil?
              end
            when 'template'
              template tempfile do
                sensitive true
                source source
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '664'
                variables variables
                source_properties.each do |k, v|
                  send(k, v)
                end unless source_properties.nil?
              end
            when 'remote_file'
              remote_file tempfile do
                sensitive true
                source source
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '664'
                source_properties.each do |k, v|
                  send(k, v)
                end unless source_properties.nil?
              end
            end
            ::File.read(tempfile)
          end

          def content_changed?(source_name, desired_content)
            !xml_to_hash(Nokogiri::XML(node.run_state['opennms']['eventconf_sources'][source_name]['definition']).root).eql?(xml_to_hash(Nokogiri::XML(desired_content).root))
          end

          def mark_changed(source_name)
            edit_resource(:ruby_block, block_name(source_name)) do
              delayed_action :run
            end
          end

          def delete_source(source_name)
            source = current_source(source_name)
            r = self
            with_run_context :root do
              declare_resource(:ruby_block, "DELETE #{source_name}") do
                block do
                  response = RestClient::Request.execute(
                    method: :delete,
                    url: "#{r.restv2url}/eventconf/sources",
                    user: 'admin',
                    password: r.admin_secret_from_vault('password'),
                    payload: "{ \"sourceIds\": [ #{source['id']} ] }",
                    headers: {
                      content_type: :json,
                      accept: :json,
                    })
                  raise "Unable to delete source #{source_name} with id #{source['id']} via API. Is OpenNMS running?" unless response.code == 200
                end
                action :nothing
                delayed_action :run
              end
            end
          end

          def upload_eventconf(body, boundary, source_name)
            response = RestClient::Request.execute(
              method: :post,
              url: "#{restv2url}/eventconf/upload",
              user: 'admin',
              password: admin_secret_from_vault('password'),
              payload: body,
              headers: {
                content_type: "multipart/form-data; boundary=#{boundary}",
                accept: :json,
              })
            raise "Unable to update content via API for eventconf source #{source_name}. Is OpenNMS running?" unless response.code == 200
          end

          private

          # node is a Nokogiri::XML node; useful for comparisons
          def xml_to_hash(node)
            {
              name: node.name,
              attributes: node.attribute_nodes
                              .sort_by(&:name)
                              .to_h { |a| [a.name, a.value] },
              text: node.element_children.empty? ? node.text.strip : nil,
              children: node.element_children.map { |c| xml_to_hash(c) },
            }
          end

          def block_name(source_name)
            "UPLOAD eventconf source #{source_name}"
          end

          def eventconf_source_resource_exist?(source_name)
            !find_resource(:ruby_block, block_name(source_name)).nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def current_source(source_name)
            sources = []
            offset = 0
            limit = 20
            total_records = 0
            source = nil
            begin
              while sources.empty? || sources.size < total_records
                resp = RestClient.get("#{restv2url}/eventconf/filter/sources?filter=#{source_name}&sortBy=fileOrder&limit=#{limit}&offset=#{offset}", { 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
                break if resp.code == 204
                ro = JSON.parse(resp.body)
                total_records = ro['totalRecords']
                sources = ro['eventConfSourceList'].select { |s| s['name'] == source_name }
                if sources&.one?
                  source = sources.first
                  break
                end
                offset += limit
              end
            rescue => e
              raise "Unable to retrieve eventconf sources from API. Is OpenNMS running? Error: #{e}"
            end
            source
          end

          def eventconf_source_resource_create(source_name, position)
            node.run_state['opennms']['eventconf_sources'] = {} if node.run_state['opennms']['eventconf_sources'].nil?
            node.run_state['opennms']['eventconf_sources'][source_name] = current_source(source_name)
            if node.run_state['opennms']['eventconf_sources'][source_name].nil?
              require 'securerandom'
              require 'rest-client'
              boundary = "----RubyMultipart#{SecureRandom.hex(16)}"
              body = ''
              body << "--#{boundary}\r\n"
              body << %(Content-Disposition: form-data; name="upload"; filename="#{source_name}.xml"\r\n)
              body << "Content-Type: application/xml\r\n"
              body << "\r\n"
              body << '<events xmlns="http://xmlns.opennms.org/xsd/eventconf"/>'
              body << "\r\n"
              if position == 'bottom'
                body << "--#{boundary}\r\n"
                body << %(Content-Disposition: form-data; name="upload"; filename=eventconf.xml\r\n)
                body << "Content-Type: application/xml\r\n"
                body << "\r\n"
                body << "<events xmlns=\"http://xmlns.opennms.org/xsd/eventconf\"><event-file>#{source_name.encode(xml: :text)}.xml</event-file></events>"
                body << "\r\n"
              end
              body << "--#{boundary}--\r\n"
              upload_eventconf(body, boundary, source_name)
              eventconf_source_resource_create(source_name, position)
            else
              begin
                response = RestClient::Request.execute(
                  method: :get,
                  url: "#{restv2url}/eventconf/sources/#{node.run_state['opennms']['eventconf_sources'][source_name]['id']}/events/download",
                  user: 'admin',
                  password: admin_secret_from_vault('password')
                )
                node.run_state['opennms']['eventconf_sources'][source_name]['definition'] = if response.code == 204
                                                                                              '<events xmlns="http://xmlns.opennms.org/xsd/eventconf"/>'
                                                                                            else
                                                                                              response.body
                                                                                            end
              rescue => e
                # At least as of 36.0.4 if the source exists but has no events, you still get a 404.
                # I think they did this to work around the fact that technically it's invalid to have an eventconf file without at least one event
                if "#{e}" == '404 Not Found'
                  node.run_state['opennms']['eventconf_sources'][source_name]['definition'] = '<events xmlns="http://xmlns.opennms.org/xsd/eventconf"/>'
                else
                  raise "Unknown error retrieving source definition: #{e}"
                end
              end
              r = self
              with_run_context :root do
                declare_resource(:ruby_block, block_name(source_name)) do
                  block do
                    require 'securerandom'
                    require 'rest-client'
                    boundary = "----RubyMultipart#{SecureRandom.hex(16)}"
                    body = ''
                    body << "--#{boundary}\r\n"
                    body << %(Content-Disposition: form-data; name="upload"; filename="#{source_name}.xml"\r\n)
                    body << "Content-Type: application/xml\r\n"
                    body << "\r\n"
                    body << node.run_state['opennms']['eventconf_sources'][source_name]['definition']
                    body << "\r\n"
                    body << "--#{boundary}--\r\n"
                    r.upload_eventconf(body, boundary, source_name)
                  end
                  action :nothing
                  delayed_action :nothing # set to :run in resource when create/update
                end
              end
            end
          end
        end

        module EventConfTemplate
          def eventconf_resource_init
            eventconf_resource_create unless eventconf_resource_exist?
          end

          def eventconf_resource
            return unless eventconf_resource_exist?
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
          end

          def ro_eventconf_resource_init
            ro_eventconf_resource_create unless ro_eventconf_resource_exist?
          end

          def ro_eventconf_resource
            return unless ro_eventconf_resource_exist?
            find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/eventconf.xml")
          end

          private

          def eventconf_resource_exist?
            !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def eventconf_resource_create
            eventconf = Opennms::Cookbook::ConfigHelpers::Event::EventConf.new
            eventconf.read!(node, "#{node['opennms']['conf']['home']}/etc/eventconf.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
            with_run_context :root do
              declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml") do
                source 'eventconf.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(eventconf: eventconf,
                          opennms_event_files: node['opennms']['opennms_event_files'],
                          vendor_event_files: node['opennms']['vendor_event_files'],
                          catch_all_event_file: node['opennms']['catch_all_event_file'],
                          secure_fields: node['opennms']['secure_fields']
                         )
                action :nothing
                delayed_action :create
                notifies :run, 'opennms_send_event[restart_Eventd]'
              end
            end
          end

          def ro_eventconf_resource_exist?
            !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/eventconf.xml").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def ro_eventconf_resource_create
            eventconf = Opennms::Cookbook::ConfigHelpers::Event::EventConf.new
            eventconf.read!(node, "#{node['opennms']['conf']['home']}/etc/eventconf.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
            with_run_context :root do
              declare_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/eventconf.xml") do
                path "#{Chef::Config[:file_cache_path]}/eventconf.xml"
                source 'eventconf.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(eventconf: eventconf,
                          opennms_event_files: node['opennms']['opennms_event_files'],
                          vendor_event_files: node['opennms']['vendor_event_files'],
                          catch_all_event_file: node['opennms']['catch_all_event_file'],
                          secure_fields: node['opennms']['secure_fields']
                         )
                action :nothing
                delayed_action :nothing
              end
            end
          end
        end

        module EventTemplate
          def eventfile_resource_init(file)
            eventfile_resource_create(file) unless eventfile_resource_exist?(file)
          end

          def eventfile_resource(file)
            return unless eventfile_resource_exist?(file)
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/#{file}")
          end

          def ro_eventfile_resource_init(file)
            ro_eventfile_resource_create(file) unless ro_eventfile_resource_exist?(file)
          end

          def ro_eventfile_resource(file)
            return unless ro_eventfile_resource_exist?(file)
            find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/#{file}")
          end

          private

          def eventfile_resource_exist?(file)
            !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/#{file}").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def eventfile_resource_create(file)
            eventfile = Opennms::Cookbook::ConfigHelpers::Event::EventDefinitionFile.new
            eventfile.read!("#{node['opennms']['conf']['home']}/etc/#{file}") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/#{file}")
            with_run_context :root do
              declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/#{file}") do
                source 'eventdef.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(eventfile: eventfile)
                action :nothing
                delayed_action :create
                notifies :run, 'opennms_send_event[restart_Eventd]'
                not_if do
                  eventfile.entries.empty?
                end
              end
            end
          end

          def ro_eventfile_resource_exist?(file)
            !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/#{file}").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def ro_eventfile_resource_create(file)
            eventfile = Opennms::Cookbook::ConfigHelpers::Event::EventDefinitionFile.new
            eventfile.read!("#{node['opennms']['conf']['home']}/etc/#{file}") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/#{file}")
            with_run_context :root do
              declare_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/#{file}") do
                path "#{Chef::Config[:file_cache_path]}/#{file}"
                source 'eventdef.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(eventfile: eventfile)
                action :nothing
                delayed_action :nothing
                not_if do
                  eventfile.entries.empty?
                end
              end
            end
          end
        end

        class EventConf
          attr_reader :event_files

          def initialize
            @event_files = {}
          end

          def read!(node, file = 'eventconf.xml')
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
            f = ::File.new(file, 'r')
            doc = REXML::Document.new f
            f.close
            position = 'override'
            seen_vendor = []
            seen_onms = []
            doc.each_element('/events/event-file') do |ef|
              event_file = ef.texts.collect(&:value).join('').strip[7..-1] if !ef.nil? && ef.respond_to?(:texts) && ef.texts.collect(&:value).join('').strip.length > 7
              if node['opennms']['opennms_event_files'].include?(event_file)
                seen_onms << event_file
                next
              end
              position = 'top' if node['opennms']['opennms_event_files'] == seen_onms
              if node['opennms']['vendor_event_files'].include?(event_file)
                seen_vendor << event_file
                next
              end
              position = 'bottom' if node['opennms']['vendor_event_files'] == seen_vendor
              break if event_file == node['opennms']['catch_all_event_file']
              @event_files[event_file] = { position: position }
              # @event_files = {} if @event_files.nil?
            end
          end

          def self.read(node, file = 'eventconf.xml')
            eventconf = new
            eventconf.read!(node, file)
            eventconf
          end
        end

        class EventDefinitionFile
          include Opennms::Cookbook::ConfigHelpers::Event::Helper
          attr_reader :entries

          def initialize
            @entries = []
          end

          def parse(doc)
            events = doc.elements['events']
            unless events.nil?
              events.each_element('event') do |event|
                mask = '!'
                unless event.elements['mask'].nil?
                  mask = mask(event)
                end
                uei = element_text(event, 'uei')
                priority = element_text(event, 'priority').to_i if !event.elements['priority'].nil? && is_positive_i?(element_text(event, 'priority'))
                event_label = element_text(event, 'event-label')
                descr = element_multiline_text(event, 'descr')
                logmsg = element_multiline_text(event, 'logmsg')
                logmsg_notify = attr_value(event, 'logmsg/@notify').downcase == 'true' unless attr_value(event, 'logmsg/@notify').nil?
                logmsg_dest = attr_value(event, 'logmsg/@dest')
                collection_group = collection_groups(event)
                severity = event.elements['severity'].texts.collect(&:value).join('').strip
                operinstruct = element_multiline_text(event, 'operinstruct')
                autoaction = autoactions(event)
                varbindsdecode = varbindsdecodes(event)
                parameters = parameters(event)
                operaction = operactions(event)
                autoacknowledge = infohash(event, 'autoacknowledge')
                loggroup = element_text(event, 'loggroup')
                tticket = infohash(event, 'tticket')
                forward = forwards(event)
                script = scripts(event)
                mouseovertext = element_multiline_text(event, 'mouseovertext')
                alarm_data = alarm_data(event)
                filters = filters(event)
                @entries.push(EventDefinition.new(uei: uei, mask: mask, priority: priority, event_label: event_label, descr: descr, logmsg: logmsg, logmsg_dest: logmsg_dest, logmsg_notify: logmsg_notify, collection_group: collection_group, severity: severity, operinstruct: operinstruct, autoaction: autoaction, varbindsdecode: varbindsdecode, parameters: parameters, operaction: operaction, autoacknowledge: autoacknowledge, loggroup: loggroup, tticket: tticket, forward: forward, script: script, mouseovertext: mouseovertext, alarm_data: alarm_data, filters: filters))
              end
            end
          end

          def load!(content)
            raise ArgumentError, 'Content empty or nil' if content.nil? || content.empty?
            doc = REXML::Document.new content
            parse(doc)
          end

          def read!(file = 'definitions.events.xml')
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            f = ::File.new(file, 'r')
            load!(f)
            f.close
          end

          def self.load(content)
            eventfile = new
            eventfile.load!(content)
            eventfile
          end

          def self.read(file = 'definitions.events.xml')
            eventfile = new
            eventfile.read!(file)
            eventfile
          end

          def to_s
            @entries.map(&:to_s).join("\n")
          end

          def to_xml
            doc = REXML::Document.new
            root = doc.add_element('events')
            root.add_namespace('http://xmlns.opennms.org/xsd/eventconf')
            @entries.each do |e|
              event = root.add_element('event')
              if !e.mask.nil? && e.mask.is_a?(Array)
                mask = event.add_element('mask')
                e.mask.each do |m|
                  if !m['mename'].nil?
                    maskelement = mask.add_element('maskelement')
                    maskelement.add_element('mename').add_text(m['mename'])
                    m['mevalue'].each do |mv|
                      maskelement.add_element('mevalue').add_text(mv)
                    end
                  else
                    varbind = mask.add_element('varbind')
                    varbind.add_element('vbnumber').add_text(m['vbnumber'])
                    m['vbvalue'].each do |vv|
                      varbind.add_element('vbvalue').add_text(vv)
                    end
                  end
                end
              end
              unless e.uei.nil?
                uei = event.add_element('uei')
                uei.add_text(e.uei)
              end
              unless e.priority.nil?
                priority = event.add_element('priority')
                priority.add_text(e.priority.to_s)
              end
              el = event.add_element('event-label')
              el.add_text(e.event_label)
              descr = event.add_element('descr')
              descr.add_text(e.descr)
              lm = event.add_element('logmsg')
              lm.attributes['notify'] = e.logmsg_notify unless e.logmsg_notify.nil?
              lm.attributes['dest'] = e.logmsg_dest
              lm.add_text(e.logmsg)
              e.collection_group.each do |cgroup|
                cg = event.add_element('collectionGroup')
                cg.attributes['name'] = cgroup['name']
                cg.attributes['resourceType'] = cgroup['resource_type'] unless cgroup['resource_type'].nil?
                cg.attributes['instance'] = cgroup['instance'] unless cgroup['instance'].nil?
                rrd = cg.add_element('rrd')
                rrd.attributes['step'] = cgroup['rrd']['step']
                rrd.attributes['heartBeat'] = cgroup['rrd']['heartbeat'] unless cgroup['rrd']['heartbeat'].nil?
                cgroup['rrd']['rra'].each do |a|
                  rra = rrd.add_element('rra')
                  rra.add_text(a)
                end
                cgroup['collections'].each do |c|
                  collection = cg.add_element('collection')
                  collection.attributes['name'] = c['name']
                  collection.attributes['rename'] = c['rename'] unless c['rename'].nil?
                  collection.attributes['type'] = c['type'] unless c['type'].nil?
                  c['param_values'].each do |pvkey, pvvalue|
                    param_value = collection.add_element('paramValue')
                    param_value.attributes['key'] = pvkey
                    param_value.attributes['value'] = pvvalue
                  end unless c['param_values'].nil?
                end unless cgroup['collections'].nil?
              end unless e.collection_group.nil?
              event.add_element('severity').add_text(e.severity)
              event.add_element('operinstruct').add_text(e.operinstruct) unless e.operinstruct.nil?
              e.autoaction.each do |aa|
                aaction = event.add_element('autoaction')
                aaction.attributes['state'] = aa['state'] unless aa['state'].nil?
                aaction.add_text(aa['action'])
              end unless e.autoaction.nil?
              e.varbindsdecode.each do |vbd|
                varbindsdecode = event.add_element('varbindsdecode')
                varbindsdecode.add_element('parmid').add_text(vbd['parmid'])
                vbd['decode'].each do |d|
                  decode = varbindsdecode.add_element('decode')
                  decode.attributes['varbindvalue'] = d['varbindvalue']
                  decode.attributes['varbinddecodedstring'] = d['varbinddecodedstring']
                end
              end unless e.varbindsdecode.nil?
              e.parameters.each do |p|
                parameter = event.add_element('parameter')
                parameter.attributes['name'] = p['name']
                parameter.attributes['value'] = p['value']
                parameter.attributes['expand'] = p['expand'] unless p['expand'].nil?
              end unless e.parameters.nil?
              e.operaction.each do |oa|
                operaction = event.add_element('operaction')
                operaction.attributes['state'] = oa['state'] unless oa['state'].nil?
                operaction.attributes['menutext'] = oa['menutext']
                operaction.add_text(oa['action'])
              end unless e.operaction.nil?
              unless e.autoacknowledge.nil?
                autoack = event.add_element('autoacknowledge')
                autoack.attributes['state'] = e.autoacknowledge['state'] unless e.autoacknowledge['state'].nil?
                autoack.add_text(e.autoacknowledge['info'])
              end
              event.add_element('loggroup').add_text(e.loggroup) unless e.loggroup.nil? || e.loggroup.empty?
              unless e.tticket.nil?
                tticket = event.add_element('tticket')
                tticket.attributes['state'] = e.tticket['state'] unless e.tticket['state'].nil?
                tticket.add_text(e.tticket['info'])
              end
              e.forward.each do |f|
                forward = event.add_element('forward')
                forward.attributes['state'] = f['state'] unless f['state'].nil?
                forward.attributes['mechanism'] = f['mechanism'] unless f['mechanism'].nil?
                forward.add_text(f['info'])
              end unless e.forward.nil?
              e.script.each do |s|
                script = event.add_element('script')
                script.attributes['language'] = s['language']
                script.add_text(s['name'])
              end unless e.script.nil?
              unless e.mouseovertext.nil?
                event.add_element('mouseovertext').add_text(e.mouseovertext)
              end
              unless e.alarm_data.nil?
                alarm_data = event.add_element('alarm-data')
                alarm_data.attributes['reduction-key'] = e.alarm_data['reduction_key']
                alarm_data.attributes['alarm-type'] = e.alarm_data['alarm_type']
                alarm_data.attributes['clear-key'] = e.alarm_data['clear_key'] unless e.alarm_data['clear_key'].nil?
                alarm_data.attributes['auto-clean'] = e.alarm_data['auto_clean'] unless e.alarm_data['auto_clean'].nil?
                alarm_data.attributes['x733-alarm-type'] = e.alarm_data['x733_alarm_type'] unless e.alarm_data['x733_alarm_type'].nil?
                alarm_data.attributes['x733-probable-cause'] = e.alarm_data['x733_probable_cause'] unless e.alarm_data['x733_probable_cause'].nil?
                e.alarm_data['update_fields'].each do |uf|
                  update_field = alarm_data.add_element('update-field')
                  update_field.attributes['field-name'] = uf['field_name']
                  update_field.attributes['update-on-reduction'] = uf['update_on_reduction'] unless uf['update_on_reduction'].nil?
                  update_field.attriubtes['value-expression'] = uf['value_expression'] unless uf['value_expression'].nil?
                end unless e.alarm_data['update_fields'].nil?
                unless e.alarm_data['managed_object_type'].nil?
                  alarm_data.add_element('managed-object').attributes['type'] = e.alarm_data['managed_object_type']
                end
              end
              next unless !e.filters.nil? && !e.filters.empty?
              filters = event.add_element('filters')
              e.filters.each do |f|
                filter = filters.add_element('filter')
                filter.attributes['eventparm'] = f['eventparm']
                filter.attributes['pattern'] = f['pattern']
                filter.attributes['replacement'] = f['replacement']
              end
            end
            xml = ''
            formatter = REXML::Formatters::Pretty.new(2)
            formatter.compact = true
            formatter.width = 100_000
            formatter.write(doc, xml)
            xml
          end

          def add(entry, position)
            @entries.insert(0, entry) if position == 'top'
            @entries.push(entry) if position == 'bottom'
          end

          def remove(entry)
            @entries.reject! { |e| e.match?(entry) }
          end

          def include?(entry)
            @entries.any? { |e| e.eql?(entry) }
          end

          def entry(uei, mask)
            entry = @entries.filter { |e| e.match_by_id?(uei, mask) }
            return if entry.nil? || entry.empty?
            raise EventDefinitionDuplicateEntry, "Duplicate event definitions found for UEI #{uei} with mask #{mask}" unless entry.one?
            entry.pop
          end

          private

          def mask(event)
            mes = []
            varbinds = []
            event.each_element('mask/maskelement') do |me|
              mer = {}
              mer['mename'] = me.elements['mename'].texts.collect(&:value).join('').strip
              mevalues = []
              me.each_element('mevalue') do |mev|
                mevalues.push mev.texts.collect(&:value).join('').strip
              end
              mer['mevalue'] = mevalues
              mes.push mer
            end
            event.each_element('mask/varbind') do |vb|
              vbr = {}
              vbr['vbnumber'] = vb.elements['vbnumber'].texts.collect(&:value).join('').strip
              vbvalues = []
              vb.each_element('vbvalue') do |vbv|
                vbvalues.push vbv.texts.collect(&:value).join('').strip
              end
              vbr['vbvalue'] = vbvalues
              varbinds.push vbr
            end
            mes + varbinds
          end

          def collection_groups(event_el)
            return if event_el.elements['collectionGroup'].nil?
            cgs = []
            event_el.each_element('collectionGroup') do |g|
              group = { 'name' => attr_value(g, '@name') }
              group['resource_type'] = attr_value(g, '@resourceType') unless g.elements['@resourceType'].nil?
              group['instance'] = attr_value(g, '@instance') unless g.elements['@instance'].nil?
              rras = []
              g.each_element('rrd/rra') do |rra|
                rras.push(element_text(rra))
              end
              group['rrd'] = { 'rra' => rras, 'step' => attr_value(g, 'rrd/@step').to_i }
              group['rrd']['heartbeat'] = attr_value(g, 'rrd/@heartBeat').to_i unless g.elements['rrd/@heartBeat'].nil?
              collections = []
              g.each_element('collection') do |c|
                collection = { 'name' => attr_value(c, '@name') }
                collection['rename'] = attr_value(c, '@rename') unless c.elements['@rename'].nil?
                collection['type'] = attr_value(c, '@type') unless c.elements['@type'].nil?
                unless c.elements['paramValue'].nil?
                  pvs = {}
                  c.each_element('paramValue') do |pv|
                    pvs[attr_value(pv, '@key')] = begin
                                                    Integer(attr_value(pv, '@value'))
                                                  rescue
                                                    attr_value(pv, '@value').to_f
                                                  end
                  end
                  collection['param_values'] = pvs
                end
                collections.push collection
              end
              group['collections'] = collections
              cgs.push group
            end
            cgs
          end

          def autoactions(event)
            return if event.elements['autoaction'].nil?
            aas = []
            event.each_element('autoaction') do |aa|
              a = {}
              a['action'] = aa.texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n")
              a['state'] = aa.attributes['state'] unless aa.attributes['state'].nil?
              aas.push(a)
            end
            aas
          end

          def varbindsdecodes(event)
            return if event.elements['varbindsdecode'].nil?
            vbds = []
            event.elements.each('varbindsdecode') do |vbd|
              parmid = element_text(vbd, 'parmid')
              decode = []
              vbd.elements.each('decode') do |d|
                varbindvalue = d.attributes['varbindvalue']
                varbinddecodedstring = d.attributes['varbinddecodedstring']
                decode.push 'varbindvalue' => varbindvalue, 'varbinddecodedstring' => varbinddecodedstring
              end
              vbds.push 'parmid' => parmid, 'decode' => decode
            end
            vbds
          end

          def parameters(event)
            return if event.elements['parameter'].nil?
            parameters = []
            event.elements.each('parameter') do |parm|
              p = { 'name' => parm.attributes['name'], 'value' => parm.attributes['value'] }
              p['expand'] = parm.attributes['expand'] == 'true' unless parm.attributes['expand'].nil?
              parameters.push p
            end
            parameters
          end

          def operactions(event)
            return if event.elements['operaction'].nil?
            oas = []
            event.each_element('operaction') do |oa|
              o = {}
              o['action'] = oa.texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n")
              o['menutext'] = oa.attributes['menutext']
              o['state'] = oa.attributes['state'] unless oa.attributes['state'].nil?
              oas.push(o)
            end
            oas
          end

          def infohash(event, xpath)
            return if event.elements[xpath].nil?
            ih = {}
            ih['info'] = element_text(event, xpath)
            ih['state'] = attr_value(event, "#{xpath}/@state") unless event.elements["#{xpath}/@state"].nil?
            ih
          end

          def forwards(event)
            return if event.elements['forward'].nil?
            forwards = []
            event.elements.each('forward') do |fwd|
              f = {}
              f['info'] = fwd.texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n")
              f['state'] = fwd.attributes['state'] unless fwd.attributes['state'].nil?
              f['mechanism'] = fwd.attributes['mechanism'] unless fwd.attributes['mechanism'].nil?
              forwards.push f
            end
            forwards
          end

          def scripts(event)
            return if event.elements['script'].nil?
            scripts = []
            event.each_element('script') do |s|
              script = {}
              script['name'] = s.texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n")
              script['language'] = s.attributes['language']
              scripts.push script
            end
            scripts
          end

          def alarm_data(events)
            return if events.elements['alarm-data'].nil?
            ad_el = events.elements['alarm-data']
            alarm_type = ad_el.attributes['alarm-type'].to_i
            reduction_key = ad_el.attributes['reduction-key']
            clear_key = ad_el.attributes['clear-key']
            auto_clean = ad_el.attributes['auto-clean'].downcase == 'true' unless ad_el.attributes['auto-clean'].nil?
            x733_alarm_type = ad_el.attributes['x733-alarm-type']
            x733_probable_cause = ad_el.attributes['x733-probable-cause']
            update_fields = nil
            unless ad_el.elements['update-field'].nil?
              update_fields = []
              ad_el.elements.each('update-field') do |uf|
                fn = uf.attributes['field-name']
                uor = !(uf.attributes['update-on-reduction'] == 'false')
                if uor.nil?
                  update_fields.push 'field_name' => fn
                else
                  update_fields.push 'field_name' => fn, 'update_on_reduction' => uor
                end
              end
            end
            managed_object_type = nil
            unless ad_el.elements['managed-object'].nil?
              managed_object_type = ad_el.elements['managed-object/@type'].value
            end
            alarm_data = {}
            alarm_data['alarm_type'] = alarm_type
            alarm_data['reduction_key'] = reduction_key
            alarm_data['clear_key'] = clear_key unless clear_key.nil?
            alarm_data['auto_clean'] = auto_clean unless auto_clean.nil?
            alarm_data['x733_alarm_type'] = x733_alarm_type unless x733_alarm_type.nil?
            alarm_data['x733_probable_cause'] = x733_probable_cause unless x733_probable_cause.nil?
            alarm_data['update_fields'] = update_fields unless update_fields.nil?
            alarm_data['managed_object_type'] = managed_object_type unless managed_object_type.nil?
            alarm_data
          end

          def filters(events)
            return if events.elements['filters'].nil?
            filters = []
            events.each_element('filters/filter') do |f|
              filters.push 'eventparm' => f.attributes['eventparm'], 'pattern' => f.attributes['pattern'], 'replacement' => f.attributes['replacement']
            end
            filters
          end
        end

        class EventDefinition
          attr_reader :uei, :mask, :priority, :event_label, :descr, :logmsg, :logmsg_dest, :logmsg_notify, :collection_group, :severity, :operinstruct, :autoaction, :varbindsdecode, :parameters, :operaction, :autoacknowledge, :loggroup, :tticket, :forward, :script, :mouseovertext, :alarm_data, :filters

          def initialize(uei:, mask:, priority: nil, event_label:, descr:, logmsg:, logmsg_dest: nil, logmsg_notify: nil, collection_group: nil, severity:, operinstruct: nil, autoaction: nil, varbindsdecode: nil, parameters: nil, operaction: nil, autoacknowledge: nil, loggroup: nil, tticket: nil, forward: nil, script: nil, mouseovertext: nil, alarm_data: nil, filters: nil)
            @uei = uei
            @mask = mask
            @priority = priority
            @event_label = event_label
            @descr = descr
            @logmsg = logmsg
            @logmsg_dest = logmsg_dest
            @logmsg_notify = logmsg_notify
            @collection_group = false.eql?(collection_group) ? nil : collection_group
            @severity = severity
            @operinstruct = operinstruct
            @autoaction = false.eql?(autoaction) ? nil : autoaction
            @varbindsdecode = false.eql?(varbindsdecode) ? nil : varbindsdecode
            @parameters = false.eql?(parameters) ? nil : parameters
            @operaction = false.eql?(operaction) ? nil : operaction
            @autoacknowledge = false.eql?(autoacknowledge) ? nil : autoacknowledge
            @loggroup = loggroup
            @tticket = false.eql?(tticket) ? nil : tticket
            @forward = false.eql?(forward) ? nil : forward
            @script = false.eql?(script) ? nil : script
            @mouseovertext = mouseovertext
            @alarm_data = false.eql?(alarm_data) ? nil : alarm_data
            @filters = false.eql?(filters) ? nil : filters
          end

          def to_s
            "uei = #{@uei}\n" \
              "mask = #{@mask}\n" \
              "priority = #{@priority}\n" \
              "event_label = #{@event_label}\n" \
              "descr = #{@descr}\n" \
              "logmsg = #{@logmsg}\n" \
              "logmsg_dest = #{@logmsg_dest}\n" \
              "logmsg_notify = #{@logmsg_notify}\n" \
              "collection_group = #{@collection_group}\n" \
              "severity = #{@severity}\n" \
              "operinstruct = #{@operinstruct}\n" \
              "autoaction = #{@autoaction}\n" \
              "varbindsdecode = #{@varbindsdecode}\n" \
              "parameters = #{@parameters}\n" \
              "operaction = #{@operaction}\n" \
              "autoacknowledge = #{@autoacknowledge}\n" \
              "loggroup = #{@loggroup}\n" \
              "tticket = #{@tticket}\n" \
              "forward = #{@forward}\n" \
              "script = #{@script}\n" \
              "mouseovertext = #{@mouseovertext}\n" \
              "alarm_data = #{@alarm_data}\n" \
              "filters = #{@filters}"
          end

          def eql?(evtdef)
            return false unless self.class.eql?(evtdef.class)
            return true if uei.eql?(evtdef.uei) &&
                           mask.eql?(evtdef.mask) &&
                           event_label.eql?(evtdef.event_label) &&
                           descr.eql?(evtdef.descr) &&
                           logmsg.eql?(evtdef.logmsg) &&
                           logmsg_dest.eql?(evtdef.logmsg_dest) &&
                           logmsg_notify.eql?(evtdef.logmsg_notify) &&
                           collection_group.eql?(evtdef.collection_group) &&
                           severity.eql?(evtdef.severity) &&
                           operinstruct.eql?(evtdef.operinstruct) &&
                           autoaction.eql?(evtdef.autoaction) &&
                           varbindsdecode.eql?(evtdef.varbindsdecode) &&
                           parameters.eql?(evtdef.parameters) &&
                           operaction.eql?(evtdef.operaction) &&
                           autoacknowledge.eql?(evtdef.autoacknowledge) &&
                           loggroup.eql?(evtdef.loggroup) &&
                           tticket.eql?(evtdef.tticket) &&
                           forward.eql?(evtdef.forward) &&
                           script.eql?(evtdef.script) &&
                           mouseovertext.eql?(evtdef.mouseovertext) &&
                           alarm_data.eql?(evtdef.alarm_data) &&
                           filters.eql?(evtdef.filters)
            false
          end

          def match?(evtdef)
            return true if @uei.eql?(evtdef.uei) && @mask.eql?(evtdef.mask)
            false
          end

          def match_by_id?(uei, mask)
            if @uei.eql?(uei)
              if mask.eql?('*')
                return true
              elsif @mask.eql?(mask)
                return true
              elsif mask.eql?('!') && @mask.nil?
                return true
              end
            end
            false
          end

          def update(priority: nil, event_label: nil, descr: nil, logmsg: nil, logmsg_dest: nil, logmsg_notify: nil, collection_group: nil, severity: nil, operinstruct: nil, autoaction: nil, varbindsdecode: nil, parameters: nil, operaction: nil, autoacknowledge: nil, loggroup: nil, tticket: nil, forward: nil, script: nil, mouseovertext: nil, alarm_data: nil, filters: nil)
            @priority = priority unless priority.nil?
            @event_label = event_label unless event_label.nil?
            @descr = descr unless descr.nil?
            @logmsg = logmsg unless logmsg.nil?
            @logmsg_dest = logmsg_dest unless logmsg_dest.nil?
            @logmsg_notify = logmsg_notify unless logmsg_notify.nil?
            @collection_group = collection_group unless collection_group.nil?
            @collection_group = nil if false.eql?(collection_group)
            @severity = severity unless severity.nil?
            @operinstruct = operinstruct unless operinstruct.nil?
            @autoaction = autoaction unless autoaction.nil?
            @autoaction = nil if false.eql?(autoaction)
            @varbindsdecode = varbindsdecode unless varbindsdecode.nil?
            @varbindsdecode = nil if false.eql?(varbindsdecode)
            @parameters = parameters unless parameters.nil?
            @parameters = nil if false.eql?(parameters)
            @operaction = operaction unless operaction.nil?
            @operaction = nil if false.eql?(operaction)
            @autoacknowledge = autoacknowledge unless autoacknowledge.nil?
            @autoacknowledge = nil if false.eql?(autoacknowledge)
            @loggroup = loggroup unless loggroup.nil?
            @tticket = tticket unless tticket.nil?
            @tticket = nil if false.eql?(tticket)
            @forward = forward unless forward.nil?
            @forward = nil if false.eql?(forward)
            @script = script unless script.nil?
            @script = nil if false.eql?(script)
            @mouseovertext = mouseovertext unless mouseovertext.nil?
            @alarm_data = alarm_data unless alarm_data.nil?
            @alarm_data = nil if false.eql?(alarm_data)
            @filters = filters unless filters.nil?
            @filters = nil if false.eql?(filters)
            self
          end

          def self.create(**properties)
            EventDefinition.new(**properties)
          end
        end

        class EventDefinitionDuplicateEntry < StandardError; end
      end
    end
  end
end
