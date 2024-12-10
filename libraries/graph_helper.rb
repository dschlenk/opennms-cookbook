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

        def cgf_resource_create(f)
          file = Opennms::Cookbook::Graph::CollectionGraphTemplate.new
          file.read!("#{onms_etc}/snmp-graph.properties.d/#{f}")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/snmp-graph.properties.d/#{f}") do
              cookbook 'opennms'
              source 'graph.properties.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
            end
          end
        end
      end

      class CollectionGraphPropertiesFile
        # TODO
      end
    end
  end
end
