module Opennms
  module Cookbook
    module ConfigHelpers
      module Jms
        class JmsNbConfig
          def initialize
            @data = {}
          end

          def read!(node, _path)
            @data[:enabled] = node['opennms']['jms_nbi']['enabled']
            @data[:nagles_delay] = node['opennms']['jms_nbi']['nagles_delay']
            @data[:batch_size] = node['opennms']['jms_nbi']['batch_size']
            @data[:queue_size] = node['opennms']['jms_nbi']['queue_size']
            @data[:message_format] = node['opennms']['jms_nbi']['message_format']
            @data[:jms_destination] = node['opennms']['jms_nbi']['jms_destination']
            @data[:uei] = node['opennms']['jms_nbi']['uei']
            @data[:send_as_object_message] = node['opennms']['jms_nbi']['send_as_object_message']
            @data[:first_occurrence_only] = node['opennms']['jms_nbi']['first_occurrence_only']
          end

          def to_hash
            @data
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
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(node, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
          with_run_context :root do
            declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml") do
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
          !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jms_nb_resource_create
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new
          config.read!(node, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml") if ::File.exist?("#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
          with_run_context :root do
            declare_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml") do
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
