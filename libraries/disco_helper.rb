module Opennms
  module Cookbook
    module Discovery
      module ConfigurationTemplate
        def disco_resource_init
          disco_resource_create unless disco_resource_exist?
        end

        def disco_resource
          return unless disco_resource_exist?
          find_resource!(:template, "#{onms_etc}/discovery-configuration.xml")
        end

        def ro_disco_resource_init
          ro_disco_resource_create unless ro_disco_resource_exist?
        end

        def ro_disco_resource
          return unless ro_disco_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/discovery-configuration.xml")
        end

        private

        def disco_resource_exist?
          !find_resource(:template, "#{onms_etc}/discovery-configuration.xml").nil?
        rescue
          false
        end

        def disco_resource_create
          c = Opennms::Cookbook::Discovery::Configuration.read("#{onms_etc}/discovery-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/discovery-configuration.xml") do
              cookbook 'opennms'
              source 'discovery-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                config: c,
                init_sleep_ms: node['opennms']['discovery']['init_sleep_ms'],
                pps: node['opennms']['discovery']['pps'],
                restart_sleep_ms: node['opennms']['discovery']['restart_sleep_ms'],
                retries: node['opennms']['discovery']['retries'],
                timeout: node['opennms']['discovery']['timeout'],
                foreign_source: node['opennms']['discovery']['foreign_source']
              )
              action :nothing
              delayed_action :create
              notifies :run, 'opennms_send_event[restart_Discovery]'
            end
          end
        end

        def ro_disco_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/discovery-configuration.xml").nil?
        rescue
          false
        end

        def ro_disco_resource_create
          c = Opennms::Cookbook::Discovery::Configuration.read("#{onms_etc}/discovery-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/discovery-configuration.xml") do
              path "#{Chef::Config[:file_cache_path]}/discovery-configuration.xml"
              cookbook 'opennms'
              source 'discovery-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                config: c
              )
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class Configuration
        include Opennms::XmlHelper
        attr_reader :specifics, :include_ranges, :exclude_ranges, :include_urls, :exclude_urls

        def initialize
          @specifics = []
          @include_ranges = []
          @exclude_ranges = []
          @include_urls = []
          @exclude_urls = []
        end

        def read!(file = 'discovery-configuration.xml')
          doc = xmldoc_from_file(file)
          doc.each_element('specific') do |s|
            @specifics.push({ ipaddr: xml_element_text(s), location: s.attributes['location'], retry_count: (s.attributes['retries'].nil? ? nil : s.attributes['retries'].to_i), timeout: (s.attributes['timeout'].to_i.nil? ? nil : s.attributes['timeout'].to_i), foreign_source: s.attributes['foreign-source'] }.compact)
          end
          doc.each_element('include-range') do |r|
            @include_ranges.push({ begin: xml_element_text(r, 'begin'), end: xml_element_text(r, 'end'), location: r.attributes['location'], retry_count: (r.attributes['retries'].nil? ? nil : r.attributes['retries'].to_i), timeout: (r.attributes['timeout'].to_i.nil? ? nil : r.attributes['timeout'].to_i), foreign_source: r.attributes['foreign-source'] }.compact)
          end
          doc.each_element('exclude-range') do |r|
            @exclude_ranges.push({ begin: xml_element_text(r, 'begin'), end: xml_element_text(r, 'end'), location: r.attributes['location'] }.compact)
          end
          doc.each_element('include-url') do |u|
            @exclude_ranges.push({ url: xml_element_text(u), location: u.attributes['location'], retry_count: (u.attributes['retries'].nil? ? nil : u.attributes['retries'].to_i), timeout: (u.attributes['timeout'].to_i.nil? ? nil : u.attributes['timeout'].to_i), foreign_source: u.attributes['foreign-source'] }.compact)
          end
          doc.each_element('exclude-url') do |u|
            @exclude_ranges.push({ url: xml_element_text(u), location: u.attributes['location'] }.compact)
          end
        end

        def specific(ipaddr:, location:)
          specific = @specifics.select { |s| s[:ipaddr].eql?(ipaddr) && s[:location].eql?(location) }
          return if specific.empty?
          raise DuplicateSpecific, "More than one specific element found with IP addr #{ipaddr} and location #{location}" unless specific.one?
          specific.pop
        end

        def add_specific(ipaddr:, location: nil, retry_count: nil, timeout: nil, foreign_source: nil)
          @specifics.push({ ipaddr: ipaddr, location: location, retry_count: retry_count, timeout: timeout, foreign_source: foreign_source }.compact)
        end

        def delete_specific(ipaddr:, location: nil)
          @specifics.delete_if { |s| s[:ipaddr].eql?(ipaddr) && s[:location].eql?(location) }
        end

        def include_range(begin_ip:, end_ip:, location:)
          include_range = @include_ranges.select { |r| r[:begin].eql?(begin_ip) && r[:end].eql?(end_ip) && r[:location].eql?(location) }
          return if include_range.empty?
          raise DuplicateIncludeRange, "More than one include_range element found with begin IP #{begin_ip}, end IP #{end_ip} and location #{location}" unless include_range.one?
          include_range.pop
        end

        def add_include_range(begin_ip:, end_ip:, location: nil, retry_count: nil, timeout: nil, foreign_source: nil)
          @include_ranges.push({ begin: begin_ip, end: end_ip, location: location, retry_count: retry_count, timeout: timeout, foreign_source: foreign_source }.compact)
        end

        def delete_include_range(begin_ip:, end_ip:, location:)
          @include_ranges.delete_if { |r| r[:begin].eql?(begin_ip) && r[:end].eql?(end_ip) && r[:location].eql?(location) }
        end

        def exclude_range(begin_ip:, end_ip:, location:)
          exclude_range = @exclude_ranges.select { |r| r[:begin].eql?(begin_ip) && r[:end].eql?(end_ip) && r[:location].eql?(location) }
          return if exclude_range.empty?
          raise DuplicateExcludeRange, "More than one exclude_range element found with begin IP #{begin_ip}, end IP #{end_ip} and location #{location}" unless exclude_range.one?
          exclude_range.pop
        end

        def add_exclude_range(begin_ip:, end_ip:, location: nil)
          @exclude_ranges.push({ begin: begin_ip, end: end_ip, location: location }.compact)
        end

        def delete_exclude_range(begin_ip:, end_ip:, location:)
          @exclude_ranges.delete_if { |r| r[:begin].eql?(begin_ip) && r[:end].eql?(end_ip) && r[:location].eql?(location) }
        end

        def include_url(url:, location:)
          include_url = @include_urls.select { |u| u[:url].eql?(url) && u[:location].eql?(location) }
          return if include_url.empty?
          raise DuplicateIncludeUrl, "More than one include_url element found with url #{url} and location #{location}" unless include_url.one?
          include_url.pop
        end

        def add_include_url(url:, location: nil, retry_count: nil, timeout: nil, foreign_source: nil)
          @include_urls.push({ url: url, location: location, retry_count: retry_count, timeout: timeout, foreign_source: foreign_source }.compact)
        end

        def delete_include_url(url:, location:)
          @include_urls.delete_if { |u| u[:url].eql?(url) && u[:location].eql?(location) }
        end

        def exclude_url(url:, location:)
          exclude_url = @exclude_urls.select { |u| u[:url].eql?(url) && u[:location].eql?(location) }
          return if exclude_url.empty?
          raise DuplicateIncludeUrl, "More than one exclude_url element found with url #{url} and location #{location}" unless exclude_url.one?
          exclude_url.pop
        end

        def add_exclude_url(url:, location: nil, retry_count: nil, timeout: nil, foreign_source: nil)
          @exclude_urls.push({ url: url, location: location, retry_count: retry_count, timeout: timeout, foreign_source: foreign_source }.compact)
        end

        def delete_exclude_url(url:, location:)
          @exclude_urls.delete_if { |u| u[:url].eql?(url) && u[:location].eql?(location) }
        end

        def self.read(file = 'discovery-configuration.xml')
          c = Configuration.new
          c.read!(file)
          c
        end
      end

      class DuplicateSpecific < StandardError; end

      class DuplicateIncludeRange < StandardError; end

      class DuplicateExcludeRange < StandardError; end

      class DuplicateIncludeUrl < StandardError; end

      class DuplicateExcludeUrl < StandardError; end
    end
  end
end
