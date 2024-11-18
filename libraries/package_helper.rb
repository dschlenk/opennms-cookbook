module Opennms
  module Cookbook
    module Collection
      module CollectdTemplate
        def collectd_resource_init
          collectd_resource_create unless collectd_resource_exist?
        end

        def collectd_resource
          return unless collectd_resource_exist?
          find_resource!(:template, "#{onms_etc}/collectd-configuration.xml")
        end

        private

        def collectd_resource_exist?
          !find_resource(:template, "#{onms_etc}/collectd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def collectd_resource_create
          file = Opennms::Cookbook::Package::CollectdConfigFile.new
          file.read!("#{onms_etc}/collectd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/collectd-configuration.xml") do
              cookbook 'opennms'
              source 'collectd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(collectd_config: file)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end
    end

    module Poller
      module PollerTemplate
        def poller_resource_init
          poller_resource_create unless poller_resource_exist?
        end

        def poller_resource
          return unless poller_resource_exist?
          find_resource!(:template, "#{onms_etc}/poller-configuration.xml")
        end

        private

        def poller_resource_exist?
          !find_resource(:template, "#{onms_etc}/poller-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def poller_resource_create
          file = Opennms::Cookbook::Package::PollerConfigFile.new
          file.read!("#{onms_etc}/poller-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/poller-configuration.xml") do
              cookbook 'opennms'
              source 'poller-configuration.xml.erb'
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
      end
    end

    module Package
      class Service
        attr_reader :service_name, :interval, :user_defined, :status, :parameters

        def initialize(service_name:, interval:, user_defined:, status:, timeout:, port:, parameters:)
          @service_name = service_name
          @interval = interval
          @user_defined = user_defined
          @status = status
          @parameters = parameters || {}
          @parameters['timeout'] = timeout unless timeout.nil?
          @parameters['port'] = port unless port.nil?
        end

        def to_s
          "service_name=#{@service_name}; " \
            "interval=#{@interval}; " \
            "user_defined=#{@user_defined}; " \
            "status=#{@status}; " \
            "parameters=#{@parameters.collect(&:to_s).join(', ')}; "
        end

        def timeout
          param_prop('timeout')
        end

        def port
          param_prop('port')
        end

        def eql?(s)
          self.class.eql?(p.class) &&
            @service_name.eql?(s.service_name) &&
            @interval.eql?(s.interval) &&
            @user_defined.eql?(s.user_defined) &&
            @status.eql?(s.status) &&
            @parameters.eql?(s.parameters)
        end

        def update(**properties)
          properties.each do |k, v|
            send(k, v) unless v.nil?
          end
        end

        def self.create(**properties)
          type = properties.delete(:type)
          case type
          when 'collectd'
            CollectdService.new(**properties)
          else
            Service.new(**properties)
          end
        end

        private

        def param_prop(k)
          return if @parameters.nil? || !@parameters.key?(k)
          @parameters[k]
        end
      end

      class CollectdService < Service
        attr_accessor :type
        def self.type_from_class_name(class_name)
          case class_name
          when 'org.opennms.protocols.xml.collector.XmlCollector'
            :xml
          when 'org.opennms.netmgt.collectd.JdbcCollector'
            :jdbc
          when 'org.opennms.netmgt.collectd.Jsr160Collector'
            :jmx
          when 'org.opennms.netmgt.collectd.SnmpCollector'
            :snmp
          when 'org.opennms.netmgt.collectd.WsManCollector'
            :wsman
          end
        end

        def initialize(service_name:, interval:, user_defined:, status:, timeout: nil, port: nil, collection: nil, retry_count: nil, thresholding_enabled: nil, parameters: nil, type: nil)
          super(service_name: service_name, interval: interval, user_defined: user_defined, status: status, timeout: timeout, port: port, parameters: parameters)
          @type = type unless type.nil?
          @parameters['collection'] = collection unless collection.nil?
          @parameters['retry'] = retry_count.to_s unless retry_count.nil?
          @parameters['thresholding-enabled'] = thresholding_enabled.to_s unless thresholding_enabled.nil?
        end

        def collection
          param_prop('collection')
        end

        def retry_count
          param_prop('retry')
        end

        def thresholding_enabled
          param_prop('thresholding-enabled')
        end

        def rmi_server_port
          param_prop('rmiServerPort')
        end

        def remote_jmx
          param_prop('remoteJMX')
        end

        def driver
          param_prop('driver')
        end

        def user
          param_prop('user')
        end

        def password
          param_prop('password')
        end

        def url
          param_prop('url')
        end

        def factory
          param_prop('factory')
        end

        def username
          param_prop('username')
        end

        def protocol
          param_prop('protocol')
        end

        def url_path
          param_prop('urlPath')
        end

        def rrd_base_name
          param_prop('rrd-base-name')
        end

        def ds_name
          param_prop('ds-name')
        end

        def friendly_name
          param_prop('friendly-name')
        end

        def update(**resource_properties)
          proxied_properties = {
            collection: 'collection',
            timeout: 'timeout',
            retry_count: 'retry',
            port: 'port',
            thresholding_enabled: 'thresholding-enabled',
          }
          case @type
          when :jmx
            proxied_properties[:rmi_server_port] = 'rmiServerPort'
            proxied_properties[:remote_jmx] = 'remoteJMX'
            proxied_properties[:username] = 'username'
            proxied_properties[:password] = 'password'
            proxied_properties[:url] = 'url'
            proxied_properties[:url_path] = 'urlPath'
            proxied_properties[:factory] = 'factory',
            proxied_properties[:protocol] = 'protocol',
            proxied_properties[:rrd_base_name] = 'rrd-base-name',
            proxied_properties[:ds_name] = 'ds-name',
            proxied_properties[:friendly_name] = 'friendly-name'
          when :jdbc
            proxied_properties[:driver] = 'driver'
            proxied_properties[:user] = 'user'
            proxied_properties[:password] = 'password'
            proxied_properties[:url] = 'url'
          end
          # When parameters is in the update, we need to preserve any property proxied items in @parameters
          # appropriate for @type otherwise they'll disappear and the user won't know why
          # unless they know that some of these properties are proxied by a parameter
          # and we don't want them to have to know that.
          # And when parameters isn't in the update, we need to assemble one by merging the proxied properties
          # and the state of the current @parameters.
          parameters = resource_properties.fetch(:parameters, {})
          parameters = {} if parameters.nil?
          proxied_properties.each do |sym, attr|
            rpv = resource_properties.fetch(sym, nil)
            rpv = rpv.to_s unless rpv.nil?
            pv = @parameters[attr]
            parameters[attr] = rpv || pv unless rpv.nil? && pv.nil?
          end
          @parameters = parameters
          # @parameters['collection'] = collection unless collection.nil?
          # @parameters['timeout'] = timeout.to_s unless timeout.nil?
          # @parameters['retry'] = retry_count.to_s unless retry_count.nil?
          # @parameters['port'] = port.to_s unless port.nil?
          # @parameters['thresholding-enabled'] = thresholding_enabled.to_s unless thresholding_enabled.nil?
          @interval = resource_properties.fetch(:interval) unless resource_properties.fetch(:interval, nil).nil?
          @user_defined = resource_properties.fetch(:user_defined) unless resource_properties.fetch(:user_defined, nil).nil?
          @status = resource_properties.fetch(:status) unless resource_properties.fetch(:status, nil).nil?
        end
      end

      class Package
        attr_reader :package_name, :filter, :specifics, :include_ranges, :exclude_ranges, :include_urls

        def initialize(package_name:, filter:, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil)
          @package_name = package_name
          @filter = filter
          @specifics = specifics || []
          @include_ranges = include_ranges || []
          @exclude_ranges = exclude_ranges || []
          @include_urls = include_urls || []
        end

        def to_s
          "package_name=#{@package_name}; " \
            "filter=#{@filter}; " \
            "specifics=#{@specifics.nil? ? 'nil' : @specifics.collect(&:to_s).join(', ')}; " \
            "include_ranges=#{@include_ranges.nil? ? 'nil' : @include_ranges.collect(&:to_s).join(', ')}; " \
            "exclude_ranges=#{@exclude_ranges.nil? ? 'nil' : @exclude_ranges.collect(&:to_s).join(', ')}; " \
            "include_urls=#{@include_urls.nil? ? 'nil' : @include_urls.collect(&:to_s).join(', ')}; "
        end

        def eql?(p)
          self.class.eql?(p.class) &&
            @package_name.eql?(p.package_name) &&
            @filter.eql?(p.filter) &&
            @specifics.eql?(p.specifics) &&
            @include_ranges.eql?(p.include_ranges) &&
            @exclude_ranges.eql?(p.exclude_ranges) &&
            @include_urls.eql?(p.include_urls)
        end

        def self.create(type:, package_name:, filter:, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil)
          case type
          when 'collectd'
            CollectdPackage.new(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls)
          when 'poller'
            PollerPackage.new(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls)
          else
            Package.new(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls)
          end
        end
      end

      class ServicePackage < Package
        attr_accessor :services, :outage_calendars

        def initialize(package_name:, filter:, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil, services: nil, outage_calendars: nil)
          super(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls)
          @services = services.nil? ? [] : services
          @outage_calendars = outage_calendars.nil? ? [] : outage_calendars
        end

        def to_s
          "#{super}; services=#{@services.nil? ? 'nil' : @services.collect(&:to_s).join(', ')}; " \
            "outage_calendars=#{@outage_calendars.nil? ? 'nil' : @outage_calendars.collect(&:to_s).join(', ')}; "
        end

        def eql?(np)
          super && @services.eql?(np.services) && @outage_calendars.eql?(np.outage_calendars)
        end

        def service(service_name:)
          svc = @services.filter { |s| s.service_name.eql?(service_name) }
          return if svc.nil? || svc.empty?
          raise DuplicateCollectdService, "More than one service named #{service_name} found in config file" unless svc.one?
          svc.pop
        end

        def delete_service(service_name:)
          @services.delete_if { |s| s.service_name.eql?(service_name) } unless @services.nil?
        end
      end

      class CollectdPackage < ServicePackage
        attr_accessor :remote, :store_by_if_alias, :store_by_node_id, :if_alias_domain, :stor_flag_override, :if_alias_comment

        def initialize(package_name:, filter:, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil, remote: nil, store_by_if_alias: nil, store_by_node_id: nil, if_alias_domain: nil, stor_flag_override: nil, if_alias_comment: nil, services: nil, outage_calendars: nil)
          super(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls, services: services, outage_calendars: outage_calendars)
          @remote = remote
          @store_by_if_alias = store_by_if_alias
          @store_by_node_id = store_by_node_id
          @if_alias_domain = if_alias_domain
          @stor_flag_override = stor_flag_override
          @if_alias_comment = if_alias_comment
        end

        def to_s
          "CollectdPackage #{super}; " \
            "remote=#{@remote}; " \
            "store_by_if_alias=#{@store_by_if_alias}; " \
            "store_by_node_id=#{@store_by_node_id}; " \
            "if_alias_domain=#{@if_alias_domain}; " \
            "stor_flag_override=#{@stor_flag_override}; " \
            "if_alias_comment=#{@if_alias_comment}."
        end

        def eql?(cp)
          super &&
            @remote.eql?(cp.remote) &&
            @store_by_if_alias.eql?(cp.store_by_if_alias) &&
            @store_by_node_id.eql?(cp.store_by_node_id) &&
            @if_alias_domain.eql?(cp.if_alias_domain) &&
            @stor_flag_override.eql?(cp.stor_flag_override) &&
            @if_alias_comment.eql?(cp.if_alias_comment)
        end

        def update(filter:, specifics:, include_ranges:, exclude_ranges:, include_urls:, outage_calendars:, store_by_if_alias:, store_by_node_id:, if_alias_domain:, stor_flag_override:, if_alias_comment:, remote:)
          @filter = filter unless filter.nil?
          @specifics = specifics unless specifics.nil?
          @include_ranges = include_ranges unless include_ranges.nil?
          @exclude_ranges = exclude_ranges unless exclude_ranges.nil?
          @include_urls = include_urls unless include_urls.nil?
          @outage_calendars = outage_calendars unless outage_calendars.nil?
          @store_by_if_alias = store_by_if_alias unless store_by_if_alias.nil?
          @store_by_node_id = store_by_node_id unless store_by_node_id.nil?
          @if_alias_domain = if_alias_domain unless if_alias_domain.nil?
          @stor_flag_override = stor_flag_override unless stor_flag_override.nil?
          @if_alias_comment = if_alias_comment unless if_alias_comment.nil?
          @remote = remote unless remote.nil?
        end
      end

      class PollerPackage < ServicePackage
        attr_accessor :remote, :rrd_step, :rras, :downtimes

        def initialize(package_name:, filter:, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil, remote: nil,  services: nil, outage_calendars: nil, rrd_step: nil, rras: nil, downtimes: nil)
          super(package_name: package_name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls, services: services, outage_calendars: outage_calendars)
          @remote = remote
          @rrd_step = rrd_step || 300
          @rras = rras || ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
          @downtimes = downtimes || { 0 => { 'interval' => 30_000, 'end' => 300_000 }, 300_000 => { 'interval' => 300_000, 'end' => 43_200_000 }, 43_200_000 => { 'interval' => 600_000, 'end' => 432_000_000 }, 432_000_000 => { 'interval' => 3600000 } }
        end

        def to_s
          "PollerPackage #{super}; " \
            "remote=#{@remote}; " \
            "rrd_step=#{@rrd_step}; " \
            "rras=#{@rras}; " \
            "downtimes=#{@downtimes}."
        end

        def eql?(pp)
          super &&
            @remote.eql?(pp.remote) &&
            @rrd_step.eql?(pp.rrd_step) &&
            @rras.eql?(pp.rras) &&
            @downtimes.eql?(pp.downtimes)
        end

        def service(service_name:)
          service = @services.select { |s| s[:service_name].eql?(service_name) }
          return if service.empty?
          raise DuplicatePollerServices, "More than one service named #{service_name} found in #{@package_name}" unless service.one?
          service.pop
        end

        def update(filter: nil, specifics: nil, include_ranges: nil, exclude_ranges: nil, include_urls: nil, outage_calendars: nil, remote: nil, rrd_step: nil, rras: nil, downtimes: nil)
          @filter = filter unless filter.nil?
          @specifics = specifics unless specifics.nil?
          @include_ranges = include_ranges unless include_ranges.nil?
          @exclude_ranges = exclude_ranges unless exclude_ranges.nil?
          @include_urls = include_urls unless include_urls.nil?
          @outage_calendars = outage_calendars unless outage_calendars.nil?
          @remote = remote unless remote.nil?
          @rrd_step = rrd_step unless rrd_step.nil?
          @rras = rras unless rras.nil?
          @downtimes = downtimes unless downtimes.nil?
        end

        def delete_service(service_name:)
          @services.delete_if { |s| s[:service_name].eql?(service_name) } unless @services.nil?
        end
      end

      class PackageConfigFile
        include Opennms::XmlHelper

        attr_reader :packages, :threads, :type

        def initialize
          @packages = {}
        end

        def to_s
          "packages=#{@packages.collect(&:to_s).join(', ')}; threads=#{@threads}"
        end

        def read!(file = 'configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          populate_packages(doc)
          populate_threads(doc)
          populate_fields(doc)
          set_service_types
        end

        def populate_packages(doc)
          doc.each_element("#{@type}-configuration/package") do |p|
            name = p.attributes['name']
            filter = p.elements['filter'].texts.collect(&:value).join('').strip
            specifics = [] unless p.elements['specific'].nil?
            p.each_element('specific') do |s|
              specifics.push(s.texts.collect(&:value).join('').strip)
            end
            include_ranges = [] unless p.elements['include-range'].nil?
            p.each_element('include-range') do |ir|
              include_ranges.push({ 'begin' => ir.attributes['begin'], 'end' => ir.attributes['end'] })
            end
            exclude_ranges = [] unless p.elements['exclude-range'].nil?
            p.each_element('exclude-range') do |er|
              exclude_ranges.push({ 'begin' => er.attributes['begin'], 'end' => er.attributes['end'] })
            end
            include_urls = [] unless p.elements['include-url'].nil?
            p.each_element('include-url') do |iu|
              include_urls.push(iu.texts.collect(&:value).join('').strip)
            end
            @packages[name] = Package.create(type: @type, package_name: name, filter: filter, specifics: specifics, include_ranges: include_ranges, exclude_ranges: exclude_ranges, include_urls: include_urls)
          end
        end

        def populate_threads(doc)
          xpath = "#{@type}-configuration/@threads"
          @threads = doc.elements[xpath].value unless doc.elements[xpath].nil?
        end

        def populate_fields(_doc)
          raise 'Unimplemented method'
        end

        def set_service_types
          raise 'Unimplemented method'
        end
      end

      class ServicePackageConfigFile < PackageConfigFile
        def populate_packages(doc)
          super
          doc.each_element("#{@type}-configuration/package") do |p|
            name = p.attributes['name']
            unless p.elements['service'].nil?
              services = []
              p.each_element('service') do |s|
                services.push(service_from_element(s))
              end
            end
            unless p.elements['outage-calendar'].nil?
              outage_calendars = []
              p.each_element('outage-calendar') do |oc|
                outage_calendars.push(oc.texts.collect(&:value).join('').strip)
              end
            end
            @packages[name].services = services unless services.nil?
            @packages[name].outage_calendars = outage_calendars unless outage_calendars.nil?
          end
        end

        def service_from_element(s)
          name = s.attributes['name']
          interval = s.attributes['interval'].to_i
          user_defined = s.attributes['user-defined'].eql?('true') unless s.elements['@user-defined'].nil?
          status = s.attributes['status'] unless s.elements['@status'].nil?
          parameters = {} unless s.elements['parameter'].nil?
          s.each_element('parameter') do |p|
            parameters[p.attributes['key']] = p.attributes['value']
          end
          { type: @type, service_name: name, interval: interval, user_defined: user_defined, status: status, parameters: parameters }
        end

        private

        def property_from_parameter(property, parameters)
          matches = parameters.select { |p| !p[property].nil? }
          return if matches.nil? || matches.empty? || !matches.one?
          matches.pop
        end
      end

      class CollectdConfigFile < ServicePackageConfigFile
        attr_reader :collectors

        def initialize
          super
          @collectors = []
          @type = 'collectd'
        end

        def populate_packages(doc)
          super
          doc.each_element("#{@type}-configuration/package") do |p|
            name = p.attributes['name']
            @packages[name].store_by_if_alias = p.elements['storeByIfAlias'].texts.collect(&:value).join('').strip.eql?('true') unless p.elements['storeByIfAlias'].nil?
            unless p.elements['storeByNodeID'].nil?
              v = p.elements['storeByNodeID'].texts.collect(&:value).join('').strip
              @packages[name].store_by_node_id = %w(true false).include?(v) ? v.eql?('true') : v
            end
            unless p.elements['storFlagOverride'].nil?
              v = p.elements['storFlagOverride'].texts.collect(&:value).join('').strip
              @packages[name].stor_flag_override = %w(true false).include?(v) ? v.eql?('true') : v
            end
            @packages[name].if_alias_domain = p.elements['ifAliasDomain'].texts.collect(&:value).join('').strip unless p.elements['ifAliasDomain'].nil?
            @packages[name].if_alias_comment = p.elements['ifAliasComment'].texts.collect(&:value).join('').strip unless p.elements['ifAliasComment'].nil?
            @packages[name].remote = p.attributes['remote'].eql?('true') unless p.attributes['remote'].nil?
          end
        end

        def populate_fields(doc)
          doc.each_element("#{@type}-configuration/collector") do |collector|
            parameters = {} unless collector.elements['parameter'].nil?
            collector.each_element('parameter') do |p|
              parameters[p.attributes['key']] = p.attributes['value']
            end
            @collectors.push({ 'service' => collector.attributes['service'], 'class_name' => collector.attributes['class-name'], 'parameters' => parameters })
          end
        end

        def service_from_element(s)
          service = super
          Service.create(**service)
        end

        def collector(service_name:)
          clct = @collectors.filter { |c| c['service'].eql?(service_name) }
          return if clct.nil? || clct.empty?
          raise DuplicateCollectorElements, "More than one `collector` element with `service` #{service_name} found in collectd-configuration.xml" unless clct.one?
          clct.pop
        end

        def delete_collector(service_name:)
          @collectors.delete_if { |c| c['service'].eql?(service_name) } unless @collectors.nil?
        end

        def set_service_types
          @packages.each do |_name, package|
            next if package.services.nil?
            package.services.each do |service|
              service.type = CollectdService.type_from_class_name(collector(service_name: service.service_name))
            end
          end
        end

        def self.read(file)
          f = CollectdConfigFile.new
          f.read!(file)
          f
        end
      end

      class PollerConfigFile < ServicePackageConfigFile
        attr_reader :next_outage_id, :service_unresponsive_enabled, :path_outage_enabled, :default_critical_path_ip, :default_critical_path_service, :default_critical_path_timeout, :default_critical_path_retries, :async_polling_engine_enabled, :max_concurrent_async_polls, :node_outage_status, :node_outage_critical_service, :node_outage_poll_all_if_no_critical_service_defined, :monitors
        def initialize
          super
          @type = 'poller'
          @monitors = []
        end

        def populate_fields(doc)
          # daemon level fields
          pc = doc.elements['poller-configuration']
          @next_outage_id = pc.attributes['nextOutageId']
          @service_unresponsive_enabled = pc.attributes['serviceUnresponsiveEnabled']
          @path_outage_enabled = pc.attributes['pathOutageEnabled']
          @default_critical_path_ip = pc.attributes['defaultCriticalPathIp']
          @default_critical_path_service = pc.attributes['defaultCriticalPathService']
          @default_critical_path_timeout = pc.attributes['defaultCriticalPathTimeout']
          @default_critical_path_retries = pc.attributes['defaultCriticalPathRetries']
          @async_polling_engine_enabled = pc.attributes['asyncPollingEngineEnabled']
          @max_concurrent_async_polls = pc.attributes['maxConcurrentAsyncPolls']
          no = doc.elements['poller-configuration/node-outage']
          @node_outage_status = no.attributes['status']
          @node_outage_critical_service = no.elements['critical-service/@name'].value
          @node_outage_poll_all_if_no_critical_service_defined = no.attributes['pollAllIfNoCriticalServiceDefined']
          # extra package fields next
          doc.each_element("#{@type}-configuration/package") do |p|
            name = p.attributes['name']
            @packages[name].rrd_step = p.elements['rrd/@step'].value.to_i
            @packages[name].rras = xml_text_array(p, 'rrd/rra')
            @packages[name].remote = p.attributes['remote'].eql?('true') unless p.attributes['remote'].nil?
            downtimes = {} unless p.elements['downtime'].nil?
            p.each_element('downtime') do |d|
              downtimes[d.attributes['begin'].to_i] = { 'interval' => d.attributes['interval'].to_i }
              downtimes[d.attributes['begin'].to_i]['end'] = d.attributes['end'].to_i unless d.attributes['end'].nil?
              downtimes[d.attributes['begin'].to_i]['delete'] = d.attributes['delete'] unless d.attributes['delete'].nil?
            end
            @packages[name].downtimes = downtimes
          end
          # monitors last
          doc.each_element("#{@type}-configuration/monitor") do |m|
            parameters = {} unless m.elements['parameter'].nil?
            m.each_element('parameter') do |p|
              unless p.elements[1].nil?
                c = ""
                c = p.elements[1].to_s
              end
              parameters[p.attributes['key']] = { 'value' => p.attributes['value'], 'configuration' => c }.compact
            end
            @monitors.push({ 'service' => m.attributes['service'], 'class_name' => m.attributes['class-name'], 'parameters' => parameters }.compact)
          end
        end

        def set_service_types
          # not needed since we don't proxy parameters based on poller service type like we do for collectors
        end

        # override to handle parameters with configuration
        def service_from_element(s)
          name = s.attributes['name']
          interval = s.attributes['interval'].to_i
          user_defined = s.attributes['user-defined'].eql?('true') unless s.elements['@user-defined'].nil?
          status = s.attributes['status'] unless s.elements['@status'].nil?
          parameters = {}
          s.each_element('parameter') do |p|
            unless p.elements[1].nil?
              c = ""
              c = p.elements[1].to_s 
            end
            parameters[p.attributes['key']] = { 'value' => p.attributes['value'], 'configuration' => c }.compact
          end
          { type: @type, service_name: name, interval: interval, user_defined: user_defined, status: status, parameters: parameters, pattern: xml_element_text(s, 'pattern')}.compact
        end

        def monitor(service_name:)
          monitor = @monitors.select { |m| m['service'].eql?(service_name) }
          return if monitor.empty?
          raise DuplicatePollerMonitor, "More than one monitor with service attribute #{service_name} found in poller configuration" unless monitor.one?
          monitor.pop
        end

        def delete_monitor(service_name:)
          @monitors.delete_if { |m| m['service'].eql?(service_name) }
        end

        def self.read(file)
          f = PollerConfigFile.new
          f.read!(file)
          f
        end
      end

      class ThreshdConfigFile < ServicePackageConfigFile
      end

      class DuplicateCollectorElements < StandardError; end

      class DuplicateCollectdService < StandardError; end
    end
  end
end
