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
                url "#{baseurl}/foreignSources"
                headers({ 'Content-Type' => 'application/xml' })
                action :nothing
                delayed_action :post
                message foreign_source.message.to_s
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
            @message = RestClient.get(url, accept: :xml).to_s
          rescue RestClient::NotFound
            @message = "<foreignSource name=#{name.encode(xml: :attr)}/>"
          end
        end
      end

      class ModelImport
        require_relative 'rbac'
        include Opennms::Rbac

        attr_reader :message

        def initialize(name, url)
          begin
            @message = RestClient.get(url, accept: :xml).to_s
          rescue RestClient::NotFound
            @message = "<model-import foreign-source=#{name.encode(xml: :attr)}/>"
          end
        end
      end
      module ModelImportHttpRequest
        require_relative 'rbac'
        include Opennms::Rbac

        def model_import_init(name)
          model_import_create(name) unless model_import_exist?(name)
        end

        def model_import(name)
          return
          find_resource!(:http_request, "opennms_import POST #{name}")
        end

        private

          def model_import_exist?(name)
            !find_resource(:http_request, "opennms_import POST #{name}").nil? unless fs_resource_exist?(name)
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def model_import_create(name)
            url = "#{baseurl}/requisitions/#{name}"
            model_import = Opennms::Cookbook::Provision::ModelImport.new(name, url)
            with_run_context(:root) do
              declare_resource(:http_request, "opennms_import POST #{name}") do
                url "#{baseurl}/requisitions"
                headers({ 'Content-Type' => 'application/xml' })
                action :nothing
                delayed_action :post
                message model_import.message.to_s
              end
            end
          end

          def model_import_sync(name, rescan)
            url = "#{baseurl}/requisitions/#{name}/import"
            url += '?rescanExisting=false' if !rescan.nil? && rescan == false
            model_import_sync = Opennms::Cookbook::Provision::ModelImport.new(name, url)
            with_run_context(:root) do
              begin
                tries ||= 3
                declare_resource(:http_request, "opennms_import POST #{name}") do
                  url "#{baseurl}/requisitions"
                  headers({ 'Content-Type' => 'application/xml' })
                  action :nothing
                  delayed_action :post
                  message model_import_sync.message.to_s
                rescue => e
                  Chef::Log.debug("Retrying import sync for #{name} #{tries}")
                  retry if (tries -= 1) > 0
                  raise e
                end
              end
            end
          end
      end
    end
  end
end
