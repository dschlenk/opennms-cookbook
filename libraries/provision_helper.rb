module Opennms
  module Cookbook
    module Provision
      module ForeignSourceHttpRequest
        require_relative 'rbac'
        include Opennms::Rbac

        def fs_resource_init(name)
          fs_resource_create(name) unless fs_resource_exist?(name)
        end

        def fs_resource(name)
          return unless fs_resource_exist?(name)
          find_resource!(:http_request, "opennms_foreign_source POST #{name}")
        end

        def ro_fs_resource_init(name, port, adminpw)
          ro_fs_resource_create(name, port, adminpw) unless ro_fs_resource_exist?(name)
        end

        def ro_fs_resource(name)
          return unless ro_fs_resource_exist?(name)
          find_resource!(:http_request, "RO opennms_foreign_source POST #{name}")
        end

        private

        def fs_resource_exist?(name)
          !find_resource(:http_request, "opennms_foreign_source POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def fs_resource_create(name)
          url = "#{baseurl}/foreignSources/#{name}"
          foreign_source = Opennms::Cookbook::Provision::ForeignSource.new(name, url)
          with_run_context(:root) do
            declare_resource(:http_request, "opennms_foreign_source POST #{name}") do
              url "#{resturl}/foreignSources"
              headers({ 'Content-Type' => 'application/xml', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
              action :nothing
              delayed_action :post
              message foreign_source.message.to_s
              sensitive true
            end
          end
        end

        def ro_fs_resource_exist?(name)
          !find_resource(:http_request, "RO opennms_foreign_source POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_fs_resource_create(name, port = 8980, adminpw = 'admin')
          url = "#{baseurl}/foreignSources/#{name}"
          foreign_source = Opennms::Cookbook::Provision::ForeignSource.new(name, url)
          with_run_context(:root) do
            declare_resource(:http_request, "RO opennms_foreign_source POST #{name}") do
              url "http://localhost:#{port}/opennms/rest}/foreignSources"
              headers({ 'Content-Type' => 'application/xml', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{adminpw}")}" })
              action :nothing
              delayed_action :nothing
              message foreign_source.message.to_s
              sensitive true
            end
          end
        end
      end

      class ForeignSource
        require_relative 'rbac'
        include Opennms::Rbac

        attr_reader :message

        def initialize(name, url)
          begin
            Chef::Log.debug("getting foreign source at url #{url}")
            @message = RestClient.get(url, accept: :xml).to_s
            Chef::Log.debug("response message:#{@message}")
          rescue RestClient::NotFound
            Chef::Log.debug("foreign source #{name} not found, returning an empty one")
            @message = "<foreignSource name=#{name.encode(xml: :attr)}/>"
          end
        end
      end

      class ModelImport
        require_relative 'rbac'
        include Opennms::Rbac

        attr_reader :message

        def initialize(foreign_source_name, url)
          begin
            @message = RestClient.get(url, accept: :xml).to_s
          rescue RestClient::NotFound
            @message = "<model-import foreign-source=#{foreign_source_name.encode(xml: :attr)}/>"
          end
        end

        def self.existing_model_import(foreign_source_name, url)
          message = nil
          begin
            message = RestClient.get(url, accept: :xml).to_s
          rescue RestClient::NotFound
            Chef::Log.debug("No requisition with name #{foreign_source_name} found")
          end
          ModelImport.new(foreign_source_name, url) unless message.nil?
        end
      end

      module ModelImportHttpRequest
        require_relative 'rbac'
        include Opennms::Rbac

        def model_import_init(name)
          model_import_create(name) unless model_import_exist?(name)
        end

        def model_import(name)
          return unless model_import_exist?(name)
          find_resource!(:http_request, "opennms_import POST #{name}")
        end

        def ro_model_import_init(name, port, adminpw)
          ro_model_import_create(name, port, adminpw) unless ro_model_import_exist?(name)
        end

        def ro_model_import(name)
          return unless ro_model_import_exist?(name)
          find_resource!(:http_request, "RO opennms_import POST #{name}")
        end

        private

        def model_import_exist?(name)
          !find_resource(:http_request, "opennms_import POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def model_import_create(name)
          url = "#{baseurl}/requisitions/#{name}"
          Chef::Log.debug "model_import_create url: #{url}"
          model_import = Opennms::Cookbook::Provision::ModelImport.new(name, url)
          with_run_context(:root) do
            declare_resource(:http_request, "opennms_import POST #{name}") do
              url "#{resturl}/requisitions"
              headers({ 'Content-Type' => 'application/xml', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
              action :nothing
              delayed_action :post
              message model_import.message.to_s
              sensitive true
            end
          end
        end

        def ro_model_import_exist?(name)
          !find_resource(:http_request, "RO opennms_import POST #{name}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_model_import_create(name, port = 8980, adminpw = 'admin')
          url = "#{baseurl}/requisitions/#{name}"
          Chef::Log.debug "model_import_create url: #{url}"
          model_import = Opennms::Cookbook::Provision::ModelImport.new(name, url)
          with_run_context(:root) do
            declare_resource(:http_request, "RO opennms_import POST #{name}") do
              url "http://localhost:#{port}/opennms/rest/requisitions"
              headers({ 'Content-Type' => 'application/xml', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{adminpw}")}" })
              action :nothing
              delayed_action :nothing
              message model_import.message.to_s
              sensitive true
            end
          end
        end

        def model_import_sync(name, rescan)
          url = "#{resturl}/requisitions/#{name}/import"
          url += '?rescanExisting=false' if !rescan.nil? && rescan == false
          with_run_context(:root) do
            declare_resource(:http_request, "sync opennms_import #{name}") do
              url url
              headers({ 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
              action :nothing
              delayed_action :put
              message ''
              retries 3
              retry_delay 10
              sensitive true
            end if find_resource(:http_request, "sync opennms_import #{name}").nil?
          end
        end

        def model_import_node_delete(fsname, fsid)
          node_url = "#{resturl}/requisitions/#{fsname}/nodes/#{fsid}"
          Chef::Log.debug "model_import_node_delete url: #{url}"
          with_run_context(:root) do
            declare_resource(:http_request, "opennms_import_node  DELETE #{fsname}") do
              url node_url
              headers({ 'Content-Type' => 'application/xml', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
              action :nothing
              delayed_action :delete
              sensitive true
            end
          end
        end
      end
    end
  end
end
