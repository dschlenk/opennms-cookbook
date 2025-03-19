# manage a package in $ONMS_HOME/etc/statsd-configuration.xml
# You don't define reports here but rather using the statsd_report
# resource and reference the name of one of these.
property :package_name, String, required: true, name_property: true
property :filter, String

include Opennms::XmlHelper
include Opennms::Cookbook::Statsd::StatsdTemplate

load_current_value do |new_resource|
  config = statsd_resource.variables[:config] unless statsd_resource.nil?
  if config.nil?
    ro_statsd_resource_init
    config = ro_statsd_resource.variables[:config]
  end
  package = config.package(name: new_resource.package_name)
  current_value_does_not_exist! if package.nil?
  filter package.filter
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Statsd::StatsdTemplate
end

action :create do
  converge_if_changed do
    statsd_resource_init
    config = statsd_resource.variables[:config]
    package = config.package(name: new_resource.package_name)
    if package.nil?
      config.add_package(name: new_resource.package_name, filter: new_resource.filter)
    else
      package.update(filter: new_resource.filter)
    end
  end
end

action :create_if_missing do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  run_action(:create) if package.nil?
end

action :update do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} found. Use action `:create` or `:create_if_missing` to create the package." if package.nil?
  run_action(:create)
end

action :delete do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  converge_by "Removing statsd package #{new_resource.package_name}" do
    config.delete_package(name: new_resource.package_name)
  end unless package.nil?
end
