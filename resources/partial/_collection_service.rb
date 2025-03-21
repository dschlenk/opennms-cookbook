include Opennms::XmlHelper
include Opennms::Cookbook::Collection::CollectdTemplate

unified_mode true
use 'partial/_service'

# on create, defaults to 'default' if not present here or in properties
property :collection, String
property :retry_count, [String, Integer]
property :thresholding_enabled, [true, false, String]

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Collection::CollectdTemplate
end

load_current_value do |new_resource|
  r = collectd_resource
  if r.nil?
    ro_collectd_resource_init
    r = ro_collectd_resource
  end
  collectd_config = r.variables[:collectd_config]
  package = collectd_config.packages[new_resource.package_name]
  current_value_does_not_exist! if package.nil?
  collector = collectd_config.collector(service_name: new_resource.service_name)
  current_value_does_not_exist! if collector.nil?
  service = package.service(service_name: new_resource.service_name)
  current_value_does_not_exist! if service.nil?
  # ignore mutex properties
  if new_resource.respond_to?(:url)
    %i(rmi_server_port remote_jmx protocol url_path).each do |p|
      if new_resource.respond_to?(p)
        send(p, new_resource.send(p))
      end
    end
  end
  # The proxied parameters are a bit tricky since the service loaded from the file
  # will always contain the parameters and the proxied property, but new_resource
  # will almost never have both.
  # Additionally, data types can be diverse, so we attempt to compare with what
  # new_resource has and fall back to the String value if it fails.
  sp = {}
  service.parameters.each do |k, v|
    case k
    when 'timeout', 'retry', 'port', 'rmiServerPort'
      sym = k.to_sym
      sym = :retry_count if 'retry'.eql?(k)
      sym = :rmi_server_port if 'rmiServerPort'.eql?(k)
      if new_resource.respond_to?(sym)
        if new_resource.send(sym).nil?
          sp[k] = service.send(sym).to_s
        elsif new_resource.send(sym).is_a?(Integer)
          value = begin
                    Integer(service.send(sym))
                  rescue
                    service.send(sym)
                  end
          send(sym, value)
        else
          send(sym, service.send(sym))
        end
      else
        sp[k] = v.to_s
      end
    when 'thresholding-enabled', 'remoteJMX'
      sym = k.to_sym
      sym = :thresholding_enabled if 'thresholding-enabled'.eql?(k)
      sym = :remote_jmx if 'remoteJMX'.eql?(k)
      if new_resource.respond_to?(sym)
        if new_resource.send(sym).nil?
          sp[k] = service.send(sym).to_s
        elsif new_resource.send(sym).is_a?(String)
          send(sym, service.send(sym))
        else
          send(sym, service.send(sym).eql?('true'))
        end
      else
        sp[k] = v.to_s
      end
    when 'collection', 'driver', 'user', 'password', 'url', 'factory', 'username', 'protocol', 'urlPath', 'rrd-base-name', 'ds-name', 'friendly-name'
      sym = k.to_sym
      sym = :url_path if 'urlPath'.eql?(k)
      sym = :rrd_base_name if 'rrd-base-name'.eql?(k)
      sym = :ds_name if 'ds-name'.eql?(k)
      sym = :friendly_name if 'friendly-name'.eql?(k)
      if new_resource.respond_to?(sym)
        if new_resource.send(sym).nil?
          sp[k] = service.send(sym).to_s
        else
          send(sym, service.send(sym))
        end
      else
        sp[k] = v.to_s
      end
    else
      sp[k] = v.to_s
    end
  end
  %i(interval user_defined status).each do |p|
    send(p, service.send(p))
  end
  # ignore driver_file for jdbc
  driver_file new_resource.driver_file if new_resource.respond_to?(:driver_file)
  parameters sp
  class_name collector['class_name']
  class_parameters collector['parameters']
end

action :create do
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      resource_properties = %i(service_name interval user_defined status collection timeout retry_count port parameters thresholding_enabled).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:interval] = 300000 if new_resource.interval.nil?
      resource_properties[:user_defined] = false if new_resource.user_defined.nil?
      resource_properties[:status] = 'on' if new_resource.status.nil?
      resource_properties[:thresholding_enabled] = false if new_resource.thresholding_enabled.nil? && (new_resource.parameters.nil? || new_resource.parameters['thresholding-enabled'].nil?)
      resource_properties[:collection] = 'default' if !resource_properties.key?(:collection) && new_resource.collection.nil? && (new_resource.parameters.nil? || new_resource.parameters['collection'].nil?)
      service = Opennms::Cookbook::Package::CollectdService.new(**resource_properties)
      # we need to set the type in case another resource updates us later in the run list
      service.type = Opennms::Cookbook::Package::CollectdService.type_from_class_name(new_resource.class_name)
      collectd_resource.variables[:collectd_config].packages[new_resource.package_name].services.push(service)
      collector = collectd_resource.variables[:collectd_config].collector(service_name: new_resource.service_name)
      if collector.nil?
        collectd_resource.variables[:collectd_config].collectors.push({ 'service' => new_resource.service_name, 'class_name' => new_resource.class_name, 'parameters' => new_resource.class_parameters })
      end
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      run_action(:create)
    end
  end
end

action :update do
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist if service.nil?
    # preserve automatic parameters for restoration
    rrd_base_name = service.parameters['rrd-base-name']
    service.update(collection: new_resource.collection, interval: new_resource.interval, user_defined: new_resource.user_defined, status: new_resource.status, timeout: new_resource.timeout, retry_count: new_resource.retry_count, port: new_resource.port, thresholding_enabled: new_resource.thresholding_enabled, parameters: new_resource.parameters)
    extras = { driver: 'driver', user: 'user', password: 'password', url: 'url', factory: 'factory', username: 'username', rrd_base_name: 'rrd-base-name', ds_name: 'ds-name', friendly_name: 'friendly-name' }
    extras.each do |sym, key|
      service.parameters[key] = new_resource.send(sym) if new_resource.respond_to?(sym) && !new_resource.send(sym).nil?
    end
    url_mutex = { rmi_server_port: 'rmiServerPort', remote_jmx: 'remoteJMX', protocol: 'protocol', url_path: 'urlPath' }
    if new_resource.respond_to?(:url) && service.parameters['url'].nil?
      url_mutex.each do |sym, key|
        service.parameters[key] = new_resource.send(sym) if new_resource.respond_to?(sym) && !new_resource.send(sym).nil?
      end
    end
    service.parameters['rrd-base-name'] = rrd_base_name unless rrd_base_name.nil? || !service.parameters['rrd-base-name'].nil?
    collector = collectd_resource.variables[:collectd_config].collector(service_name: new_resource.service_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist if collector.nil?
    collector['class-name'] = new_resource.class_name
    collector['parameters'] = new_resource.class_parameters unless new_resource.class_parameters.nil?
  end
end

action :delete do
  collectd_resource_init
  package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
  service = package.service(service_name: new_resource.service_name)
  collector = collectd_resource.variables[:collectd_config].collector(service_name: new_resource.service_name)
  if !service.nil? || !collector.nil?
    converge_by("Removing collection service #{new_resource.service_name} from #{new_resource.package_name}") do
      collectd_resource.variables[:collectd_config].packages[new_resource.package_name].delete_service(service_name: new_resource.service_name) unless package.nil?
      collectd_resource.variables[:collectd_config].delete_collector(service_name: new_resource.service_name)
    end
  end
end
