module Opennms
  module Cookbook
    module Provision
      module ForeignSourceHttpRequest
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
          foreign_source = Opennms::Cookbook::Provision::ForeignSource.new(name)
          with_run_context(:root) do
            declare_resource(:http_request, "opennms_foreign_source POST #{name}") do
              url foreign_source.url
              action :nothing
              delayed_action :post
              message foreign_source.message.to_s
            end
          end
        end
      end

      class ForeignSource
        include Opennms::Rbac
        attr_reader :url, :message

        def initialize(name)
          @url = "#{baseurl}/foreignSources/#{name}"
          begin
            @message = RestClient.get("#{baseurl}/foreignSources/#{name}", accept: :xml).to_s
          rescue RestClient::NotFound
            @message = "<foreignSource name=#{name.encode(xml: :attr)}/>"
          end
        end
      end
    end
  end
end
