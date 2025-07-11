module Opennms
  module Cookbook
    module ConfigHelpers
      module Jms
        class JmsNbConfig
          include Opennms::XmlHelper

          def initialize
            @data = {}
            @data[:destinations] = []
            Chef::Log.debug('[JmsNbConfig] Initialized with empty data structure.')
          end

          def read!(file)
            Chef::Log.info("[JmsNbConfig] Reading JMS configuration from: #{file}")
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            doc = xmldoc_from_file(file)
            root = doc.root

            @data[:enabled] = text_at_xpath(root, '/jms-northbounder-configuration/enabled')
            @data[:nagles_delay] = text_at_xpath(root, '/jms-northbounder-configuration/nagles-delay')
            @data[:batch_size] = text_at_xpath(root, '/jms-northbounder-configuration/batch-size')
            @data[:queue_size] = text_at_xpath(root, '/jms-northbounder-configuration/queue-size')
            @data[:message_format] = text_at_xpath(root, '/jms-northbounder-configuration/message-format')
            @data[:jms_destination] = text_at_xpath(root, '/jms-northbounder-configuration/jms-destination')
            @data[:uei] = text_at_xpath(root, '/jms-northbounder-configuration/uei')
            @data[:send_as_object_message] = text_at_xpath(root, '/jms-northbounder-configuration/send-as-object-message') == 'true'
            @data[:first_occurrence_only] = text_at_xpath(root, '/jms-northbounder-configuration/first-occurrence-only') == 'true'

            Chef::Log.debug("[JmsNbConfig] Parsed global config: #{@data.except(:destinations)}")

            root.elements.each('destination') do |dest_el|
              destination = Opennms::Cookbook::Jms::JmsDestination.new(
                destination: text_at_xpath(dest_el, 'jms-destination'),
                first_occurrence_only: text_at_xpath(dest_el, 'first-occurrence-only') == 'true',
                send_as_object_message: text_at_xpath(dest_el, 'send-as-object-message') == 'true',
                destination_type: text_at_xpath(dest_el, 'destination-type') || 'QUEUE',
                message_format: text_at_xpath(dest_el, 'message-format')
              )
              Chef::Log.debug("[JmsNbConfig] Loaded destination: #{destination.inspect}")
              @data[:destinations] << destination
            end

            Chef::Log.info("[JmsNbConfig] Finished reading JMS configuration. Total destinations: #{@data[:destinations].size}")
          end

          def method_missing(method, *args, &block)
            return @data[method] if @data.key?(method)
            super
          end

          def respond_to_missing?(method, include_private = false)
            @data.key?(method) || super
          end

          def to_hash
            @data
          end

          def jms_destination
            @data[:jms_destination]
          end

          def destination_value
            jms_destination
          end

          def destinations
            @data[:destinations]
          end

          def find_destination_by_name(name)
            Chef::Log.debug("[JmsNbConfig] Searching for destination: #{name}")
            found = destinations.find { |d| d.destination == name }
            Chef::Log.debug("[JmsNbConfig] Destination found: #{found.inspect}") if found
            found
          end

          def delete_destination(destination:)
            Chef::Log.info("[JmsNbConfig] Deleting destination: #{destination}")
            before_count = @data[:destinations].size
            @data[:destinations].reject! { |d| d.destination == destination }
            after_count = @data[:destinations].size
            Chef::Log.info("[JmsNbConfig] Deleted #{before_count - after_count} destination(s).")
          end

          private

          def text_at_xpath(root, path)
            el = root.elements[path]
            value = el&.text
            Chef::Log.debug("[JmsNbConfig] Extracted text at '#{path}': #{value.inspect}")
            value
          end
        end
      end
    end
  end
end

module Opennms
  module Cookbook
    module Jms
      class JmsDestination
        attr_accessor :destination, :first_occurrence_only, :send_as_object_message, :destination_type, :message_format

        def initialize(destination:, first_occurrence_only:, send_as_object_message:, destination_type:, message_format:)
          @destination = destination
          @first_occurrence_only = first_occurrence_only
          @send_as_object_message = send_as_object_message
          @destination_type = destination_type
          @message_format = message_format
        end

        def update(first_occurrence_only:, send_as_object_message:, destination_type:, message_format:)
          @first_occurrence_only = first_occurrence_only
          @send_as_object_message = send_as_object_message
          @destination_type = destination_type
          @message_format = message_format
        end

        def to_xml
          <<~XML
            <destination>
              <first-occurrence-only>#{@first_occurrence_only}</first-occurrence-only>
              <send-as-object-message>#{@send_as_object_message}</send-as-object-message>
              <destination-type>#{@destination_type}</destination-type>
              <jms-destination>#{@destination}</jms-destination>
              <message-format>#{@message_format}</message-format>
            </destination>
          XML
        end
      end

      module JmsNbTemplate
        def jms_nb_resource_init
          jms_nb_resource_create unless jms_nb_resource_exist?
        end

        def jms_nb_resource
          return unless jms_nb_resource_exist?
          find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
        end

        def ro_jms_nb_resource_init
          ro_jms_nb_resource_create unless ro_jms_nb_resource_exist?
        end

        def ro_jms_nb_resource
          return unless ro_jms_nb_resource_exist?
          find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml")
        end

        private

        def jms_nb_resource_exist?
          !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def jms_nb_resource_create
          config_path = "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml"
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new

          if ::File.exist?(config_path)
            Chef::Log.info("[JmsNbTemplate] Reading config from: #{config_path}")
            config.read!(config_path)
          else
            Chef::Log.warn("[JmsNbTemplate] JMS config file #{config_path} does not exist. Initializing empty config.")
          end

          with_run_context :root do
            declare_resource(:template, config_path) do
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: config)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]', :delayed
            end
          end
        end

        def ro_jms_nb_resource_exist?
          !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jms_nb_resource_create
          config_path = "#{node['opennms']['conf']['home']}/etc/jms-northbounder-configuration.xml"
          config = Opennms::Cookbook::ConfigHelpers::Jms::JmsNbConfig.new

          if ::File.exist?(config_path)
            Chef::Log.info("[JmsNbTemplate] Reading RO config from: #{config_path}")
            config.read!(config_path)
          else
            Chef::Log.warn("[JmsNbTemplate] RO: JMS config file #{config_path} does not exist. Initializing empty config.")
          end

          with_run_context :root do
            declare_resource(:template, "RO #{config_path}") do
              path "#{Chef::Config[:file_cache_path]}/jms-northbounder-configuration.xml"
              source 'jms-northbounder-configuration.xml.erb'
              cookbook 'opennms'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: config)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end
    end
  end
end
