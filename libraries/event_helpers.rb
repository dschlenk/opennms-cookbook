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

        module EventConfTemplate
          def eventconf_resource_init
            eventconf_resource_create unless eventconf_resource_exist?
          end

          def eventconf_resource
            return unless eventconf_resource_exist?
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
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
        end

        module EventTemplate
          def eventfile_resource_init(file)
            eventfile_resource_create(file) unless eventfile_resource_exist?(file)
          end

          def eventfile_resource(file)
            return unless eventfile_resource_exist?(file)
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/#{file}")
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
            doc.each_element('/events/event-file') do |ef|
              event_file = ef.texts.collect(&:value).join('').strip[7..-1] if !ef.nil? && ef.respond_to?(:texts) && ef.texts.collect(&:value).join('').strip.length > 7
              if node['opennms']['opennms_event_files'].include?(event_file)
                position = 'top' if position != 'top'
                next
              end
              if node['opennms']['vendor_event_files'].include?(event_file)
                position = 'bottom' if position != 'bottom'
                next
              end
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

          def read!(file = 'definitions.events.xml')
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            f = ::File.new(file, 'r')
            doc = REXML::Document.new f
            f.close

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

          def self.read(file = 'definitions.events.xml')
            eventfile = new
            eventfile.read!(file)
            eventfile
          end

          def to_s
            @entries.map(&:to_s).join("\n")
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
