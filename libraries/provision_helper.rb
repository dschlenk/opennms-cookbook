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

      module ModelImportHttpRequest
        require_relative 'rbac'
        include Opennms::Rbac

        def model_import_init(name)
          model_import_create(name) unless model_import_exist?(name)
        end

        def model_import(name)
          return unless model_import_exist?(name)
          find_resource!(:http_request, "opennms_foreign_source POST #{name}")
        end

        private

          def model_import_exist?(name)
            !find_resource(:http_request, "opennms_foreign_source POST #{name}").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def model_import_create(name)
            url = "#{baseurl}/requisitions/#{name}"
            model_import = Opennms::Cookbook::Provision::ModelImport.new(name, url)
            with_run_context(:root) do
              declare_resource(:http_request, "opennms_foreign_source POST #{name}") do
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
                declare_resource(:http_request, "opennms_foreign_source POST #{name}") do
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

            def wait_for_sync(name, wait_periods, wait_length)
              now = Time.now
              # sometimes syncs happen real quick
              now -= 60
              now = now.strftime '%Y-%m-%d %H:%M:%S'
              period = 0
              until sync_complete?(name, now) || period == wait_periods
                Chef::Log.debug "Waiting period ##{period}/#{wait_periods} for #{wait_length} seconds for requisition #{name} import to finish."
                sleep(wait_length)
                period += 1
              end
              Chef::Log.warn "Waited #{(wait_periods * wait_length)} seconds for #{name} to import, giving up. If a service restart occurs before it finishes, this and any pending requisitions may need to be synchronized manually." if period == wait_periods
            end

            def sync_complete?(name, after)
              require 'rest-client'
              require 'addressable/uri'
              api = 'v1'
              m = node['opennms']['version'].match(/^(\d+)\.(\d+)\.(\d+)-(\d+)$/)
              unless m.nil?
                if m[1].to_i > 20
                  api = 'v2'
                elsif m[1].to_i == 20 && m[2].to_i == 0 && m[3].to_i >= '2'
                  api = 'v2'
                elsif m[1].to_i == 20 && m[2].to_i > 0
                  api = 'v2'
                end
              end
              case api
              when 'v1'
                url = "#{baseurl(node)}/events?eventUei=uei.opennms.org/internal/importer/importSuccessful&eventParms=%25#{name}%25&comparator=like&query=eventcreatetime >= '#{after}'"
              when 'v2'
                url = "#{baseurlv2(node)}/events?_s=eventCreateTime=ge=#{Time.parse(after + ' ' + Time.now.zone).utc.strftime('%FT%T.%LZ')};eventUei==uei.opennms.org/internal/importer/importSuccessful"
              end
              parsed_url = Addressable::URI.parse(url).normalize.to_str
              Chef::Log.debug("sync_complete? URL: '#{parsed_url}'")
              response = RestClient.get(parsed_url, accept: :json, 'Accept-Encoding' => 'identity')
              # apiv2 returns empty response (204) when nothing found
              # and might return things in gzip format which annoyingly rest-client doesn't decode for you
              return false if response.code == 204
              if response.headers[:content_encoding] == 'gzip'
                Chef::Log.debug('dealing with gzip content')
                begin
                  sio = StringIO.new(response.body)
                  gz = Zlib::GzipReader.new(sio)
                  response = gz.read()
                rescue StandardError => err
                  Chef::Log.warn("response body indicated gzip but extraction failed due to #{err}")
                  Chef::Log.debug("response body that failed to extract is #{response.body}. Will attempt to read as JSON string.")
                  response = response.body
                end
              else Chef::Log.debug("not dealing with gzip content, headers are #{response.headers} and content encoding is #{response.headers[:content_encoding]}")
              response = response.to_s
              end
              begin
                events = JSON.parse(response) unless response.nil? || response.empty?
              rescue
                Chef::Log.warn('unparseable response from events API, assuming not found')
                return false
              end
              complete = true
              complete = false if !events.nil? && events.key?('totalCount') && events['totalCount'].to_i == 0
              if events.nil? || (api == 'v2' && !apiv2synced?(events, name))
                complete = false
              end
              complete
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
    end
  end
end
