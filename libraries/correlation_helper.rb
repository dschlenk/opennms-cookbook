module Opennms
  module Cookbook
    module Correlation
      module DroolsRuleTemplate
        require 'rexml/document'

        def base_path(rule_name)
          ::File.join(node['opennms']['conf']['home'], 'etc', 'drools-engine.d', rule_name)
        end

        def correlation_exists?(rule_name)
          dir = base_path(rule_name)
          ::File.directory?(dir) && ::File.exist?(::File.join(dir, 'drools-engine.xml'))
        end

        def engine_names(rule_name)
          xml_path = ::File.join(base_path(rule_name), 'drools-engine.xml')
          return [] unless ::File.exist?(xml_path)

          xml_content = ::File.read(xml_path)
          doc = REXML::Document.new(xml_content)

          names = []
          doc.elements.each('engine-configuration/rule-set') do |element|
            names << element.attributes['name']
          end
          names
        rescue StandardError => e
          Chef::Log.warn("Failed to parse drools-engine.xml: #{e}")
          []
        end

        def resolve_drl_filename(drl_file, drl_source_type)
          case drl_source_type
          when 'template'
            drl_file.sub(/\.erb$/, '')
          when 'remote_file'
            ::File.basename(drl_file)
          else
            drl_file
          end
        end

        # def drools_engine_resource_init(rule_name)
        #   drools_engine_resource_create(rule_name) unless drools_engine_resource_exist?(rule_name)
        # end

        # def drools_engine_resource(rule_name)
        #   return unless drools_engine_resource_exist?(rule_name)
        #   find_resource!(:template, ::File.join(base_path(rule_name), 'drools-engine.xml'))
        # end

        # private

        # def drools_engine_resource_exist?(rule_name)
        #   !find_resource(:template, ::File.join(base_path(rule_name), 'drools-engine.xml')).nil?
        # rescue Chef::Exceptions::ResourceNotFound
        #   false
        # end

        # def drools_engine_resource_create(rule_name)
        #   with_run_context(:root) do
        #     declare_resource(:template, ::File.join(base_path(rule_name), 'drools-engine.xml')) do
        #       source 'drools-engine.xml.erb'
        #       cookbook 'opennms'
        #       owner node['opennms']['username']
        #       group node['opennms']['groupname']
        #       mode '0644'
        #       action :nothing
        #       delayed_action :create
        #     end
        #   end
        # end
      end
    end
  end
end
