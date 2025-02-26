include Opennms::XmlHelper
include Opennms::Cookbook::Threshold::ThreshdTemplate
include Opennms::Cookbook::Threshold::Helper

use 'partial/_package'
unified_mode true

# array of hashes of the form
# [{ 'name' => 'SNMP', 'interval' => Integer, 'status' => 'on|off', 'params' => {'key' => 'value', ... }}, ...]
property :services, Array, callbacks: {
  'should be an array of hashes with keys `name` (String, required), `interval` (Integer, required), `status` (`on` or `off`, required), `params` (Hash of Strings, optional)' => lambda { |p|
    !p.any? { |h| !h.key?('name') || !h['name'].is_a?(String) || !h.key?('interval') || !h['interval'].is_a?(Integer) || !h.key?('status') || !(h['status'].eql?('on') || h['status'].eql?('off')) || (h.key?('params') && h['params'].any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }) }
  },
}

action_class do
  include Opennms::Cookbook::Threshold::ThreshdTemplate
end

load_current_value do |new_resource|
  threshd_config = if threshd_resource.nil?
                     Opennms::Cookbook::Package::ThreshdConfigFile.read("#{onms_etc}/threshd-configuration.xml")
                   else
                     threshd_resource.variables[:config]
                   end
  package = threshd_config.packages[new_resource.package_name]
  current_value_does_not_exist! if package.nil?
  adapted_services = string_service_adapter(package.services)
  %i(filter specifics include_ranges exclude_ranges include_urls outage_calendars).each do |p|
    send(p, package.send(p))
  end
  services adapted_services
end

action :create do
  converge_if_changed do
    threshd_resource_init
    package = threshd_resource.variables[:config].packages[new_resource.package_name]
    if package.nil?
      rp = %i(package_name filter specifics include_ranges exclude_ranges include_urls outage_calendars).map { |p| [p, new_resource.send(p)] }.to_h.compact
      rp[:services] = symbol_service_adapter(new_resource.services) unless new_resource.services.nil?
      threshd_resource.variables[:config].packages[new_resource.package_name] = Opennms::Cookbook::Package::ThreshdPackage.new(**rp)
    else
      run_action(:update)
    end
  end
end
action :create_if_missing do
  converge_if_changed do
    threshd_resource_init
    package = threshd_resource.variables[:config].packages[new_resource.package_name]
    if package.nil?
      run_action(:create)
    end
  end
end
action :update do
  converge_if_changed do
    threshd_resource_init
    config = threshd_resource.variables[:config]
    package = config.packages[new_resource.package_name]
    raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} found to update. Use the `:create` action to make a new package" if package.nil?
    ssvcs = symbol_service_adapter(new_resource.services) unless new_resource.services.nil?
    package.update(filter: new_resource.filter, specifics: new_resource.specifics, include_ranges: new_resource.include_ranges, exclude_ranges: new_resource.exclude_ranges, include_urls: new_resource.include_urls, outage_calendars: new_resource.outage_calendars, services: ssvcs)
  end
end
action :delete do
  threshd_resource_init
  config = threshd_resource.variables[:config]
  package = config.packages[new_resource.package_name]
  unless package.nil?
    converge_by "Removing threshd package #{new_resource.package_name}" do
      config.packages.delete(new_resource.package_name)
    end
  end
end
