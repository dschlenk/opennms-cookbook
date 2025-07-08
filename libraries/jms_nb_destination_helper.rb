module Opennms
  module Cookbook
    module ConfigHelpers
      module Jms
        class JmsNbConfig
          include Opennms::XmlHelper

          def initialize
            @data = {}
          end

          def read!(file)
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            doc = xmldoc_from_file(file)
            root = doc.root

            @data[:enabled] = text_at_xpath(root, '/jms-northbounder-configuration/enabled')
            @data[:nagles_delay] = text_at_xpath(root, '/jms-northbounder-configuration/nagles-delay')
            @data[:batch_size] = text_at_xpath(root, '/jms-northbounder-configuration/batch-size')
            @data[:queue_size] = text_at_xpath(root, '/jms-northbounder-configuration/queue-size')
            @data[:message_format] = text_at_xpath(root, '/jms-northbounder-configuration/message-format')

            destination_el = root.elements['destination']
            if destination_el
              @data[:first_occurrence_only] = text_at_xpath(destination_el, 'first-occurence-only') == 'true'
              @data[:send_as_object_message] = text_at_xpath(destination_el, 'send-as-object-message') == 'true'
              @data[:destination_type] = text_at_xpath(destination_el, 'destination-type')
              @data[:jms_destination] = text_at_xpath(destination_el, 'jms-destination')
              @data[:destination_message_format] = text_at_xpath(destination_el, 'message-format')
            end

            @data[:ueis] = root.get_elements('uei').map(&:text)
          end

          def method_missing(method, *args, &block)
            return @data[method] if @data.key?(method)
            super
          end

          def respond_to_missing?(method, include_private = false)
            @data.key?(method) || super
          end

          def to_hash
            @data
          end

          def jms_destination
            @data[:jms_destination]
          end

          def destination
            jms_destination
          end

          private

          def text_at_xpath(root, path)
            el = root.elements[path]
            el&.text
          end
        end
      end
    end
  end
end

module Opennms
  module Cookbook
    module Jms
      module JmsNbTemplate
        def jms_nb_resource_init
          jms_nb_resource_create unless jms_nb_resource_exist?
        end

        def jms_nb_resource
          return unless jms_nb_resource_exist?
          find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
        end

        def ro_jms_nb_resource_init
          ro_jms_nb_resource_create unless ro_jms_nb_resource_exist?
        end

        def ro_jms_nb_resource
          return unless ro_jms_nb_resource_exist?
          find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
        end

        private

        def jms_nb_resource_exist?
          !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def jms_nb_resource_create
          config_path = "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml"
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(config_path) if ::File.exist?(config_path)

          with_run_context :root do
            declare_resource(:template, config_path) do
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: config)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_jms_nb_resource_exist?
          !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jms_nb_resource_create
          config_path = "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml"
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(config_path) if ::File.exist?(config_path)

          with_run_context :root do
            declare_resource(:template, "RO #{config_path}") do
              path "#{Chef::Config[:file_cache_path]}/jms-northbounder-configuration.xml"
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: config)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end
    end
  end
end
