include Opennms::XmlHelper
include Opennms::Cookbook::Poller::PollerTemplate

unified_mode true
use 'partial/_class_service'

property :pattern, String
property :parameters, Hash, callbacks: {
  'should be a hash with a string key and a hash value with key `value` with string value and optional key `configuration` which must be a string of a complete and valid single XML element (with children)' => lambda { |p|
    !p.any? do |k, v|
      !k.is_a?(String) || !v.is_a?(Hash) || (v.key?('value') && !v['value'].is_a?(String)) || (v.key?('configuration') && (!v['configuration'].is_a?(String) || !begin
                                                                                                                                                                                 REXML::Document.new(v['configuration'])
                                                                                                                                                                 rescue
                                                                                                                                                                   false
                                                                                                                                                                               end))
    end
  },
}
property :class_parameters, Hash, callbacks: {
  'should be a hash with a string key and a hash value with key `value` with string value and optional key `configuration` which must be a string of a complete and valid single XML element (with children)' => lambda { |p|
    !p.any? do |k, v|
      !k.is_a?(String) || !v.is_a?(Hash) || (v.key?('value') && !v['value'].is_a?(String)) || (v.key?('configuration') && (!v['configuration'].is_a?(String) || !begin
                                                                                                                                                                                 REXML::Document.new(v['configuration'])
                                                                                                                                                                 rescue
                                                                                                                                                                   false
                                                                                                                                                                               end))
    end
  },
}

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Poller::PollerTemplate
end

load_current_value do |new_resource|
  r = poller_resource
  if r.nil?
    ro_poller_resource_init
    r = ro_poller_resource
  end
  config = r.variables[:config]
  package = config.packages[new_resource.package_name]
  current_value_does_not_exist! if package.nil?
  monitor = config.monitor(service_name: new_resource.service_name)
  current_value_does_not_exist! if monitor.nil?
  service = package.service(service_name: new_resource.service_name)
  current_value_does_not_exist! if service.nil?
  sp = {}
  service[:parameters].each do |k, v|
    sp[k] = v
  end unless service[:parameters].nil?
  %i(interval user_defined status).each do |p|
    send(p, service[p])
  end
  pattern service[:pattern]
  parameters sp
  class_name monitor['class_name']
  class_parameters monitor['parameters']
end

action :create do
  converge_if_changed do
    poller_resource_init
    package = poller_resource.variables[:config].packages[new_resource.package_name]
    raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} exists in poller configuration" if package.nil?
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      resource_properties = %i(service_name interval user_defined status pattern parameters).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:interval] = 300000 if new_resource.interval.nil?
      resource_properties[:user_defined] = false if new_resource.user_defined.nil?
      resource_properties[:status] = 'on' if new_resource.status.nil?
      resource_properties[:parameters] = {} if resource_properties[:parameters].nil?
      poller_resource.variables[:config].packages[new_resource.package_name].services.push(resource_properties)
      monitor = poller_resource.variables[:config].monitor(service_name: new_resource.service_name)
      poller_resource.variables[:config].monitors.push({ 'service' => new_resource.service_name, 'class_name' => new_resource.class_name, 'parameters' => new_resource.class_parameters }) if monitor.nil?
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  converge_if_changed do
    poller_resource_init
    package = poller_resource.variables[:config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      run_action(:create)
    end
  end
end

action :update do
  converge_if_changed do
    poller_resource_init
    package = poller_resource.variables[:config].packages[new_resource.package_name]
    raise Chef::Exceptions::CurrentValueDoesNotExist if package.nil?
    service = package.service(service_name: new_resource.service_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist if service.nil?
    service[:interval] = new_resource.interval unless new_resource.interval.nil?
    service[:user_defined] = new_resource.user_defined unless new_resource.user_defined.nil?
    service[:status] = new_resource.status unless new_resource.status.nil?
    service[:pattern] = new_resource.pattern unless new_resource.pattern.nil?
    service[:parameters] = new_resource.parameters unless new_resource.parameters.nil?
    monitor = poller_resource.variables[:config].monitor(service_name: new_resource.service_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist if monitor.nil?
    monitor['class_name'] = new_resource.class_name
    monitor['parameters'] = new_resource.class_parameters unless new_resource.class_parameters.nil?
  end
end

action :delete do
  poller_resource_init
  package = poller_resource.variables[:config].packages[new_resource.package_name]
  service = package.service(service_name: new_resource.service_name) unless package.nil?
  monitor = poller_resource.variables[:config].monitor(service_name: new_resource.service_name)
  if !service.nil? || !monitor.nil?
    converge_by("Removing collection service #{new_resource.service_name} from #{new_resource.package_name}") do
      poller_resource.variables[:config].packages[new_resource.package_name].delete_service(service_name: new_resource.service_name) unless package.nil?
      poller_resource.variables[:config].delete_monitor(service_name: new_resource.service_name)
    end
  end
end
