require 'json'
require 'net/http'
require 'uri'

module Opennms
  module Trapd
    class ApiBackend
      def initialize(node)
        @node = node
      end

      #
      # Load the authoritative current state.
      #
      # We intentionally use /trapd/download instead of
      # /trapd/config because /trapd/config masks passphrases,
      # which would break Chef idempotency.
      #
      def load
        uri = URI(download_url)

        request = Net::HTTP::Get.new(uri)

        request['Accept'] = 'application/json'

        request.basic_auth(
          username,
          password
        )

        response =
          Net::HTTP.start(
            uri.hostname,
            uri.port,
            use_ssl: uri.scheme == 'https'
          ) do |http|
            http.request(request)
          end

        raise response.body unless response.code.to_i == 200

        JSON.parse(response.body)
      end

      def queue_write(resource, config)
        initialize_update_resource(
          resource,
          config
        )

        resource.notifies(
          :put,
          'http_request[opennms trapd put]',
          :delayed
        )
      end

      private

      def initialize_update_resource(resource, config)
        return if @node.run_state['trapd_api_resource']

        resource.with_run_context :root do
          resource.http_request 'opennms trapd put' do
            action :nothing

            url config_url

            headers(
              'Accept' => 'application/json',
              'Content-Type' => 'application/json'
            )

            message lazy do
              JSON.generate(
                config.desired
              )
            end
          end
        end

        @node.run_state['trapd_api_resource'] = true
      end

      def config_url
        "#{base_url}/api/v2/trapd/config"
      end

      def download_url
        "#{base_url}/api/v2/trapd/download"
      end

      def base_url
        @node['opennms']['url']
      end

      def username
        @node['opennms']['admin']['username']
      end

      def password
        @node['opennms']['admin']['password']
      end
    end
  end
end
