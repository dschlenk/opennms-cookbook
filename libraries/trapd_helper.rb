module Opennms
  module Cookbook
    module Trapd
      module ConfigTemplate
        def trapd_resource_init
          trapd_resource_create unless trapd_resource_exist?
        end

        def trapd_resource
          return unless trapd_resource_exist?
          if node['opennms']['version'].to_i >= 36
            find_resource!(:http_request, 'trapd config PUT')
          else
            find_resource!(:template, "#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml")
          end
        end

        def update_trapd_resource(config)
          if node['opennms']['version'].to_i >= 36
            trapd_resource.message(config.to_json)
          else
            trapd_resource.variables(config: config)
          end
        end

        def ro_trapd_resource_init
          ro_trapd_resource_create unless ro_trapd_resource_exist?
        end

        def ro_trapd_resource
          return unless ro_trapd_resource_exist?
          if node['opennms']['version'].to_i >= 36
            find_resource!(:http_request, 'RO trapd config PUT')
          else
            find_resource!(:template, "RO #{node['opennms']['conf']['home']}/etc/trapd-configuration.xml")
          end
        end

        private

        def trapd_resource_exist?
          if node['opennms']['version'].to_i >= 36
            !find_resource(:http_request, 'trapd config PUT').nil?
          else
            !find_resource(:template, "#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml").nil?
          end
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def trapd_resource_create
          config = Opennms::Cookbook::Trapd::Config.new
          if node['opennms']['version'].to_i >= 36
            config.read!("#{restv2url}/trapd/download?format=xml", { 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
          elsif ::File.exist?("#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml")
            config.read!("file://#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml")
          else
            raise "trapd-configuration.xml not found in #{node['opennms']['conf']['home']}/etc"
          end
          with_run_context :root do
            if node['opennms']['version'].to_i >= 36
              require 'json'
              declare_resource(:http_request, 'trapd config PUT') do
                url "#{restv2url}/trapd/config"
                headers({ 'Content-Type' => 'application/json', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
                message config.to_json
                sensitive true
                action :nothing
                delayed_action :put
              end
            else
              declare_resource(:template, "#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml") do
                source 'trapd-configuration.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0600'
                variables(config: config)
                action :nothing
                delayed_action :create
              end
            end
          end
        end

        def ro_trapd_resource_exist?
          if node['opennms']['version'].to_i >= 36
            !find_resource(:http_request, 'RO trapd config PUT').nil?
          else
            !find_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/trapd-configuration.xml").nil?
          end
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_trapd_resource_create
          config = Opennms::Cookbook::Trapd::Config.new
          if node['opennms']['version'].to_i >= 36
            config.read!("#{restv2url}/trapd/download?format=xml", { 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
          else
            config.read!("file://#{node['opennms']['conf']['home']}/etc/trapd-configuration.xml")
          end
          with_run_context :root do
            if node['opennms']['version'].to_i >= 36
              declare_resource(:http_request, 'RO trapd config PUT') do
                url "#{restv2url}/trapd/config"
                message config.to_json
                headers({ 'Content-Type' => 'application/json', 'Authorization' => "Basic #{Base64.strict_encode64("admin:#{admin_secret_from_vault('password')}")}" })
                action :nothing
                delayed_action :put
              end
            else
              declare_resource(:template, "RO #{node['opennms']['conf']['home']}/etc/trapd-configuration.xml") do
                path "#{Chef::Config[:file_cache_path]}/trapd-configuration.xml"
                source 'trapd-configuration.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0600'
                variables(config: config)
                action :nothing
                delayed_action :nothing
              end
            end
          end
        end

        def config_from_resource(resource)
          if node['opennms']['version'].to_i >= 36
            config = Opennms::Cookbook::Trapd::Config.new
            config.snmp_trap_address = resource.message['snmp_trap_address']
            config.snmp_trap_port = resource.message['snmp_trap_port']
            config.new_suspect_on_trap = resource.message['new_suspect_on_trap']
            config.include_raw_message = resource.message['include_raw_message']
            config.threads = resource.message['threads']
            config.queue_size = resource.message['queue_size']
            config.batch_size = resource.message['batch_size']
            config.batch_interval = resource.message['batch_interval']
            config.use_address_from_varbind = resource.message['use_address_from_varbind']
            config.snmpv3_users = resource.message['snmpv3_users'].map do |user|
              Opennms::Cookbook::Trapd::ConfigTemplate::Snmpv3User.new(
                id: user['id'],
                engine_id: user['engine_id'],
                security_name: user['security_name'],
                security_level: user['security_level'],
                auth_protocol: user['auth_protocol'],
                auth_passphrase: user['auth_passphrase'],
                privacy_protocol: user['privacy_protocol'],
                privacy_passphrase: user['privacy_passphrase']
              )
            end
          else
            config = resource.variables[:config]
          end
          config
        end
      end

      class Config
        SECURITY_LEVELS = {
          'NOAUTH_NOPRIV' => 1,
          'AUTH_NOPRIV' => 2,
          'AUTH_PRIV' => 3,
        }.freeze

        SECURITY_LEVEL_NAMES = SECURITY_LEVELS.invert.freeze

        attr_accessor :snmp_trap_address, :snmp_trap_port, :new_suspect_on_trap, :include_raw_message, :threads, :queue_size, :batch_size, :batch_interval, :use_address_from_varbind, :snmpv3_users

        def initialize
          @snmpv3_users = []
        end

        def read!(url, headers = nil)
          require 'nokogiri'
          require 'open-uri'
          raise ArgumentError, 'URL must be a string' unless url.is_a?(String)
          if url.start_with?('file://') && !url.start_with?('file:///opt/opennms/etc/')
            raise ArgumentError, 'file paths must start with /opt/opennms/etc/'
          elsif url.start_with?('file://')
            doc = Nokogiri::XML(File.read(url[7..-1]))
          else
            doc = Nokogiri::XML(URI.open(url, headers))
          end
          @snmp_trap_address = doc.at_xpath('/xmlns:trapd-configuration/@snmp-trap-address')&.value
          @snmp_trap_port = doc.at_xpath('/xmlns:trapd-configuration/@snmp-trap-port')&.value
          @new_suspect_on_trap = doc.at_xpath('/xmlns:trapd-configuration/@new-suspect-on-trap')&.value
          @include_raw_message = doc.at_xpath('/xmlns:trapd-configuration/@include-raw-message')&.value
          @threads = doc.at_xpath('/xmlns:trapd-configuration/@threads')&.value
          @queue_size = doc.at_xpath('/xmlns:trapd-configuration/@queue-size')&.value
          @batch_size = doc.at_xpath('/xmlns:trapd-configuration/@batch-size')&.value
          @batch_interval = doc.at_xpath('/xmlns:trapd-configuration/@batch-interval')&.value
          @use_address_from_varbind = doc.at_xpath('/xmlns:trapd-configuration/@use-address-from-varbind')&.value

          doc.xpath('/xmlns:trapd-configuration/xmlns:snmpv3-user').each do |user_node|
            user = {
              id: user_node.at_xpath('@id')&.value,
              engine_id: user_node.at_xpath('@engine-id')&.value,
              security_name: user_node.at_xpath('@security-name')&.value,
              security_level: user_node.at_xpath('@security-level')&.value.to_i,
              auth_protocol: user_node.at_xpath('@auth-protocol')&.value,
              auth_passphrase: user_node.at_xpath('@auth-passphrase')&.value,
              privacy_protocol: user_node.at_xpath('@privacy-protocol')&.value,
              privacy_passphrase: user_node.at_xpath('@privacy-passphrase')&.value,
            }
            @snmpv3_users << Snmpv3User.new(**user)
          end
        end

        def add_snmpv3_user(user)
          raise ArgumentError, 'Argument must be an instance of Snmpv3User' unless user.is_a?(Snmpv3User)
          if !@snmpv3_users.any? { |u| u.identity == user.identity }
            @snmpv3_users << user
          else
            raise ArgumentError, "Snmpv3User with identity #{user.identity} already exists"
          end
        end

        def remove_snmpv3_user(user)
          raise ArgumentError, 'Argument must be an instance of Snmpv3User' unless user.is_a?(Snmpv3User)
          @snmpv3_users.reject! { |u| u.identity == user.identity }
        end

        def user_for_identity(engine_id = nil, security_name = nil, security_level = nil, auth_protocol = nil, privacy_protocol = nil)
          identity = "#{engine_id}:#{security_name}:#{SECURITY_LEVELS[security_level]}:#{auth_protocol}:#{privacy_protocol}"
          user = @snmpv3_users.select { |u| u.identity == identity }
          return if user.empty?
          raise ArgumentError, "Multiple users found for identity ##{engine_id}:#{security_name}:#{SECURITY_LEVELS[security_level]}:#{auth_protocol}:#{privacy_protocol}" unless user.one?
          user.pop
        end

        def to_s
          "snmp_trap_address=#{@snmp_trap_address}, snmp_trap_port=#{@snmp_trap_port}, new_suspect_on_trap=#{@new_suspect_on_trap}, include_raw_message=#{@include_raw_message}, threads=#{@threads}, queue_size=#{@queue_size}, batch_size=#{@batch_size}, batch_interval=#{@batch_interval}, use_address_from_varbind=#{@use_address_from_varbind}, snmpv3_users=#{@snmpv3_users}"
        end

        def to_xml
          require 'builder'
          xml = Builder::XmlMarkup.new(indent: 2)
          xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
          xml.trapd_configuration(
            'snmp-trap-address' => @snmp_trap_address,
            'snmp-trap-port' => @snmp_trap_port,
            'new-suspect-on-trap' => @new_suspect_on_trap,
            'include-raw-message' => @include_raw_message,
            'threads' => @threads,
            'queue-size' => @queue_size,
            'batch-size' => @batch_size,
            'batch-interval' => @batch_interval,
            'use-address-from-varbind' => @use_address_from_varbind
          ) do
            @snmpv3_users.each do |user|
              xml.snmpv3_user(
                'id' => user.id,
                'engine-id' => user.engine_id,
                'security-name' => user.security_name,
                'security-level' => user.security_level,
                'auth-protocol' => user.auth_protocol,
                'auth-passphrase' => user.auth_passphrase,
                'priv-protocol' => user.privacy_protocol,
                'priv-password' => user.privacy_passphrase
              )
            end
          end
        end

        def self.read(url = 'file:///opt/opennms/etc/trapd-configuration.xml')
          config = Config.new
          config.read!(url)
          config
        end
      end

      class Snmpv3User
        attr_accessor :id, :engine_id, :security_name, :security_level, :auth_protocol, :auth_passphrase, :privacy_protocol, :privacy_passphrase

        def initialize(id: nil, engine_id: nil, security_name: nil, security_level: nil, auth_protocol: nil, auth_passphrase: nil, privacy_protocol: nil, privacy_passphrase: nil)
          @id = id
          @engine_id = engine_id&.freeze
          @security_name = security_name&.freeze
          @security_level = security_level&.freeze
          @auth_protocol = auth_protocol&.freeze
          @auth_passphrase = auth_passphrase
          @privacy_protocol = privacy_protocol&.freeze
          @privacy_passphrase = privacy_passphrase
        end

        def to_s
          "id=#{@id}, engine_id=#{@engine_id}, security_name=#{@security_name}, security_level=#{@security_level}, auth_protocol=#{@auth_protocol}, auth_passphrase=#{@auth_passphrase}, privacy_protocol=#{@privacy_protocol}, privacy_passphrase=#{@privacy_passphrase}"
        end

        def identity
          "#{@engine_id}:#{@security_name}:#{@security_level}:#{@auth_protocol}:#{@privacy_protocol}"
        end
      end
    end
  end
end
