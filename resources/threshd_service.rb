include Opennms::XmlHelper
include Opennms::Cookbook::Threshold::ThreshdTemplate

unified_mode true
use 'partial/_base_service'

property :parameters, Array, callbacks: {
  'should be an array of hashes with key/value pairs that are both strings' => lambda { |p|
    !p.any? { |h| !h.is_a?(Hash) || !h.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } }
  },
}

action_class do
  include Opennms::XmlHelper
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
  service = package.service(service_name: new_resource.service_name)
  current_value_does_not_exist! if service.nil?
  %i(interval user_defined status parameters).each do |p|
    send(p, service[p])
  end
end

action :create do
  converge_if_changed do
    threshd_resource_init
    package = threshd_resource.variables[:config].packages[new_resource.package_name]
    raise Chef::Exceptions::ValidationFailed, "package #{new_resource.package_name} must exist before service #{new_resource.service_name} can be added to it" if package.nil?
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      s = %i(service_name interval user_defined status parameters).map { |p| [p, new_resource.send(p)] }.to_h.compact
      s[:interval] = 300000 unless s.key?(:interval)
      s[:user_defined] = false unless s.key?(:user_defined)
      s[:status] = 'on' unless s.key?(:status)
      package.services.push(s)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  threshd_resource_init
  package = threshd_resource.variables[:config].packages[new_resource.package_name]
  raise Chef::Exceptions::ValidationFailed, "package #{new_resource.package_name} must exist before service #{new_resource.service_name} can be added to it" if package.nil?
  service = package.service(service_name: new_resource.service_name)
  run_action(:create) if service.nil?
end

action :update do
  converge_if_changed do
    threshd_resource_init
    package = threshd_resource.variables[:config].packages[new_resource.package_name]
    raise Chef::Exceptions::ValidationFailed, "Cannot update service #{new_resource.service_name} in #{new_resource.package_name} because the package does not exist" if package.nil?
    service = package.service(service_name: new_resource.service_name)
    raise Chef::Exceptions::ResourceNotFound, "Service #{new_resource.service_name} must exist before it can be updated" if service.nil?
    %i(interval user_defined status parameters).each do |p|
      service[p] = new_resource.send(p) unless new_resource.send(p).nil?
    end
  end
end

action :delete do
  threshd_resource_init
  package = threshd_resource.variables[:config].packages[new_resource.package_name]
  if package.service(service_name: new_resource.service_name)
    converge_by "Removing service #{new_resource.service_name} from threshd package #{new_resource.package_name}" do
      package.delete_service(service_name: new_resource.service_name)
    end
  end
end
