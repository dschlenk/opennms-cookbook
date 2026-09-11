require 'nokogiri'

module Opennms
  module Trapd
    class XmlBackend
      def initialize(node)
        @node = node
      end

      def load
        doc = Nokogiri::XML(
          ::File.read(xml_path)
        )

        root = doc.at_xpath('/trapd-configuration')

        {
          'batchInterval' =>
            root['batch-interval']&.to_i,

          'batchSize' =>
            root['batch-size']&.to_i,

          'includeRawMessage' =>
            root['include-raw-message'] == 'true',

          'newSuspectOnTrap' =>
            root['new-suspect-on-trap'] == 'true',

          'queueSize' =>
            root['queue-size']&.to_i,

          'snmpTrapAddress' =>
            root['snmp-trap-address'],

          'snmpTrapPort' =>
            root['snmp-trap-port']&.to_i,

          'threads' =>
            root['threads']&.to_i,

          'useAddressFromVarbind' =>
            root['use-address-from-varbind'] == 'true',

          'snmpv3User' =>
            parse_users(doc),
        }
      end

      def queue_write(resource, config)
        initialize_template_resource(resource, config)

        resource.notifies(
          :create,
          'template[trapd configuration]',
          :delayed
        )
      end

      private

      def initialize_template_resource(resource, config)
        return if @node.run_state['trapd_xml_resource']

        resource.with_run_context :root do
          resource.template 'trapd configuration' do
            path xml_path

            cookbook 'opennms'
            source 'trapd-configuration.xml.erb'

            action :nothing

            variables lazy {
              {
                trapd: config.desired,
              }
            }

            notifies :restart,
                     'service[opennms]',
                     :delayed
          end
        end

        @node.run_state['trapd_xml_resource'] = true
      end

      def parse_users(doc)
        doc.xpath('//snmpv3-user').map do |u|
          {
            'securityName' => u['security-name'],
            'engineId' => u['engine-id'],
            'securityLevel' => u['security-level'],
            'authProtocol' => u['auth-protocol'],
            'authPassphrase' => u['auth-passphrase'],
            'privacyProtocol' => u['privacy-protocol'],
            'privacyPassphrase' => u['privacy-passphrase'],
          }
        end
      end

      def xml_path
        "#{@node['opennms']['home']}/etc/trapd-configuration.xml"
      end
    end
  end
end
