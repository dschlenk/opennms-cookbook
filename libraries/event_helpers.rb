module Opennms
  module Cookbook
    module ConfigHelpers
      module Event
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
            eventconf.read!("#{node['opennms']['conf']['home']}/etc/eventconf.xml", node) if ::File.exist?("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
            with_run_context :root do
              declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/eventconf.xml") do
                source 'eventconf.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode 0664
                variables(eventconf: eventconf, 
                          opennms_event_files: node['opennms']['opennms_event_files'],
                          vendor_event_files: node['opennms']['vendor_event_files'],
                          catch_all_event_file: node['opennms']['catch_all_event_file'],
                          secure_fields: node['opennms']['secure_fields'],
                         )
                action :nothing
                delayed_action :create
                notifies :run, 'opennms_send_event[restart_Eventd]'
              end
            end
          end
        end

        class EventConf
          attr_reader :event_files

          def initialize
            @event_files = {}
          end

          def read!(file = 'eventconf.xml', node)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
            f = ::File.new(file, 'r')
            doc = REXML::Document.new f
            f.close
            position = 'override'
            ec = doc.each_element('/events/event-file') do |ef|
              event_file = ef.texts.join('').strip[7..-1] if !ef.nil? && ef.respond_to?(:texts) && ef.texts.join('').strip.length > 7
              if node['opennms']['opennms_event_files'].include?(event_file)
                position = 'top' if position != 'top'
                next
              end
              if node['opennms']['vendor_event_files'].include?(event_file)
                position = 'bottom' if position != 'bottom'
                next
              end
              break if event_file == node['opennms']['catch_all_event_file']
              # @event_files = {} if @event_files.nil?
              @event_files[event_file] = { :position => position }
            end
          end

          def self.read(file = 'eventconf.xml', node)
            eventconf = new
            eventconf.read!(file, node)
            eventconf
          end
        end
      end
    end
  end
end

