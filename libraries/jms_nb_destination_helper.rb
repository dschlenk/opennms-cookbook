module Opennms
  module Cookbook
    module ConfigHelpers
      module Jms
        class JmsNbConfig
          include Opennms::XmlHelper

          def initialize
            @data = {}
          end

          def read!(file = "#{Chef::Config[:file_cache_path]}/jms-northbounder-configuration.xml")
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            doc = xmldoc_from_file(file)
            root = doc.root

            @data[:enabled] = text_to_bool(root.elements['enabled']&.text)
            @data[:nagles_delay] = root.elements['nagles-delay']&.text.to_i
            @data[:batch_size] = root.elements['batch-size']&.text.to_i
            @data[:queue_size] = root.elements['queue-size']&.text.to_i
            @data[:message_format] = root.elements['message-format']&.text

            destination = root.elements['destination']
            if destination
              @data[:first_occurrence_only] = text_to_bool(destination.elements['first-occurence-only']&.text)
              @data[:send_as_object_message] = text_to_bool(destination.elements['send-as-object-message']&.text)
              @data[:jms_destination] = destination.elements['jms-destination']&.text
            end
          end

          def to_hash
            @data
          end

          private

          def text_to_bool(val)
            val.to_s.strip.downcase == 'true'
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
          find_resource!(:template, jms_config_path)
        end

        def ro_jms_nb_resource_init
          ro_jms_nb_resource_create unless ro_jms_nb_resource_exist?
        end

        def ro_jms_nb_resource
          return unless ro_jms_nb_resource_exist?
          find_resource!(:template, "RO #{jms_config_path}")
        end

        private

        def jms_config_path
          "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml"
        end

        def jms_nb_resource_exist?
          !find_resource(:template, jms_config_path).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def jms_nb_resource_create
          file_path = jms_config_path
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(file_path) if ::File.exist?(file_path)

          with_run_context :root do
            declare_resource(:template, file_path) do
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config.to_hash)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_jms_nb_resource_exist?
          !find_resource(:template, "RO #{jms_config_path}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jms_nb_resource_create
          file_path = jms_config_path
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(file_path) if ::File.exist?(file_path)

          with_run_context :root do
            declare_resource(:template, "RO #{jms_config_path}") do
              path "#{Chef::Config[:file_cache_path]}/jms-northbounder-configuration.xml"
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config.to_hash)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end
    end
  end
end
