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
