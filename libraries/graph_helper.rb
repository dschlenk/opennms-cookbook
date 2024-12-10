module Opennms
  module Cookbook
    module Graph
      module CollectionGraphTemplate
        def cgf_resource_init(file = 'graph.properties')
          cgf_resource_create(file) unless cgf_resource_exist?(file)
        end

        def cgf_resource(file = 'graph.properties')
          return unless cgf_resource_exist?(file)
          find_resource!(:template, "#{onms_etc}/snmp-graph.properties.d/#{file}")
        end

        private

        def cgf_resource_exist?(file)
          !find_resource(:template, "#{onms_etc}/snmp-graph.properties.d/#{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def cgf_resource_create(file)
          file = Opennms::Cookbook::Graph::CollectionGraphTemplate.new
          file.read!("#{onms_etc}/snmp-graph.properties.d/#{file}")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/cgf-configuration.xml") do
              cookbook 'opennms'
              source 'cgf-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(cgf_config: file)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end

      class CollectionGraphPropertiesFile
      end
    end
  end
end
