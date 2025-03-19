module Opennms
  module Cookbook
    module Syslog
      module ConfigurationTemplate
        def syslog_resource_init
          syslog_resource_create unless syslog_resource_exist?
        end

        def syslog_resource
          return unless syslog_resource_exist?
          find_resource!(:template, "#{onms_etc}/syslogd-configuration.xml")
        end

        def ro_syslog_resource_init
          ro_syslog_resource_create unless ro_syslog_resource_exist?
        end

        def ro_syslog_resource
          return unless ro_syslog_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/syslogd-configuration.xml")
        end

        private

        def syslog_resource_exist?
          !find_resource(:template, "#{onms_etc}/syslogd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def syslog_resource_create
          file = Opennms::Cookbook::Syslog::Configuration.new(node)
          file.read!("#{onms_etc}/syslogd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/syslogd-configuration.xml") do
              cookbook 'opennms'
              source 'syslogd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_syslog_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/syslogd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_syslog_resource_create
          file = Opennms::Cookbook::Syslog::Configuration.new(node)
          file.read!("#{onms_etc}/syslogd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/syslogd-configuration.xml") do
              path "#{Chef::Config[:file_cache_path]}/syslogd-configuration.xml"
              cookbook 'opennms'
              source 'syslogd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class Configuration
        include Opennms::XmlHelper

        attr_reader :node, :syslog_port, :new_suspect_on_message, :parser, :forwarding_regexp, :matching_group_host, :matching_group_message, :discard_uei, :timezone, :files

        def initialize(node)
          @node = node
          @files = []
        end

        # prefer node attributes if set (they default to nil) to current values in the file
        def read!(file = 'syslogd-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          config = doc.elements['/syslogd-configuration/configuration']
          @syslog_port = @node['opennms']['syslogd']['port'] || config.attributes['syslog-port']
          @new_suspect_on_message = @node['opennms']['syslogd']['new_suspect'] || config.attributes['new-suspect-on-message']
          @parser = @node['opennms']['syslogd']['parser'] || config.attributes['parser']
          @forwarding_regexp = @node['opennms']['syslogd']['forwarding_regexp'] || config.attributes['forwarding-regexp']
          @matching_group_host = @node['opennms']['syslogd']['matching_group_host'] || config.attributes['matching-group-host']
          @matching_group_message = @node['opennms']['syslogd']['matching_group_message'] || config.attributes['matching-group-message']
          @discard_uei = @node['opennms']['syslogd']['discard_uei'] || config.attributes['discard-uei']
          @timezone = @node['opennms']['syslogd']['timezone'] || config.attributes['timezone']
          @files = xml_text_array(config, '/syslogd-configuration/import-file') || []
        end

        def self.read(file, node)
          f = Configuration.new(node)
          f.read!(file)
          f
        end
      end
    end
  end
end
