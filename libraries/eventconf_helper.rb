module Opennms
  module Cookbook
    module EventConf
      module HttpRequest
        require_relative 'rbac'
        include Opennms::Rbac

        def eventconf_source_resource_init(name)
          eventconf_source_create(name) unless eventconf_source_exist?(name)
        end

        def eventconf_source(name)
          return unless eventconf_source_exist?(name)
          find_resource!(:http_request, "opennms_eventconf_source POST #{name}")
        end

        def ro_eventconf_source_init(name, port, adminpw)
          ro_eventconf_source_create(name, port, adminpw) unless ro_eventconf_source_exist?(name)
        end

        def ro_eventconf_source(name)
          return unless ro_eventconf_source_exist?(name)
          find_resource!(:http_request, "RO opennms_eventconf_source POST #{name}")
        end

        private

        def eventconf_source_exist?(name)
          !find_resource(:http_request, "opennms_eventconf_source POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def eventconf_source_create(name)
          with_run_context(:root) do
            declare_resource(:http_request, "opennms_eventconf_source POST #{name}") do
              url "#{resturl}/eventconf/sources/eventConfSource"
              headers({ 'Content-Type' => 'application/json', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
              action :nothing
              delayed_action :post
              message {}.to_json
              sensitive true
            end
          end
        end

        def ro_eventconf_source_exist?(name)
          !find_resource(:http_request, "RO opennms_eventconf_source POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_eventconf_source_create(name, port = 8980, adminpw = 'admin')
          with_run_context(:root) do
            declare_resource(:http_request, "RO opennms_eventconf_source POST #{name}") do
              url "http://localhost:#{port}/opennms/api/v2/eventconf/sources"
              headers({ 'Content-Type' => 'application/json', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{adminpw}")}" })
              action :nothing
              delayed_action :nothing
              message {}.to_json
              sensitive true
            end
          end
        end
      end
    end
  end
end
