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
        require 'java-properties'
        attr_reader :reports

        def initialize
          @reports = []
        end

        def read!(file = 'graph.properties')
          require 'java-properties'
          props = JavaProperties::Properties.new(file)
          reports = props[:reports].split(/,\s*/) unless props[:reports].nil?
          reports.each do |report|
            # each report has at least a name, columns, type, command and maybe propertiesValues, description, suppress
            @reports.push({ 'name' => props["report.#{report}.name".to_sym], 'columns' => props["report.#{report}.columns".to_sym].split(/,\s*/), 'command' => props["report.#{report}.command".to_sym], 'propertiesValues' => props["report.#{report}.propertiesValues".to_sym], 'description' => props["report.#{report}.description".to_sym], 'suppress' => props["report.#{report}.suppress".to_sym] }.compact)
          end
        end

        def self.read(file = 'graph.properties')
          cgpf = CollectionGraphPropertiesFile.new
          cgpf.read!(file)
          cgpf
        end
      end
    end
  end
end
