include Opennms::XmlHelper
unified_mode true

use 'partial/_package'
property :store_by_if_alias, [true, false]
property :store_by_node_id, [String, true, false]
property :if_alias_domain, String
property :stor_flag_override, [true, false]
property :if_alias_comment, String
property :remote, [true, false]

action_class do
  include Opennms::Cookbook::Collection::CollectdTemplate
end

include Opennms::Cookbook::Collection::CollectdTemplate
load_current_value do |new_resource|
  r = collectd_resource
  if r.nil?
    filename = "#{onms_etc}/collectd-configuration.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collectd_config = Opennms::Cookbook::Package::CollectdConfigFile.read(filename)
  else
    collectd_config = r.variables[:collectd_config]
  end
  package = collectd_config.packages[new_resource.package_name]
  current_value_does_not_exist! if package.nil?
  %i(filter specifics include_ranges exclude_ranges include_urls outage_calendars store_by_if_alias store_by_node_id if_alias_domain stor_flag_override if_alias_comment remote).each do |p|
    send(p, package.send(p))
  end
end

action :create do
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    if package.nil?
      resource_properties = %i(package_name filter specifics include_ranges exclude_ranges include_urls outage_calendars store_by_if_alias store_by_node_id if_alias_domain stor_flag_override if_alias_comment remote).map { |p| [p, new_resource.send(p)] }.to_h.compact
      package = Opennms::Cookbook::Package::CollectdPackage.new(**resource_properties)
      collectd_resource.variables[:collectd_config].packages[new_resource.package_name] = package
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  collectd_resource_init
  package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
  run_action(:create) if package.nil?
end

action :update do
  converge_if_changed(:filter, :specifics, :include_ranges, :exclude_ranges, :include_urls, :outage_calendars, :store_by_if_alias, :store_by_node_id, :if_alias_domain, :stor_flag_override, :if_alias_comment, :remote) do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    raise Chef::Exceptions::CurrentValueDoesNotExist if package.nil?
    package.update(filter: new_resource.filter, specifics: new_resource.specifics, include_ranges: new_resource.include_ranges, exclude_ranges: new_resource.exclude_ranges, include_urls: new_resource.include_urls, outage_calendars: new_resource.outage_calendars, store_by_if_alias: new_resource.store_by_if_alias, store_by_node_id: new_resource.store_by_node_id, if_alias_domain: new_resource.if_alias_domain, stor_flag_override: new_resource.stor_flag_override, if_alias_comment: new_resource.if_alias_comment, remote: new_resource.remote)
  end
end

action :delete do
  collectd_resource_init
  package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
  unless package.nil?
    converge_by("Removing collection package #{new_resource.package_name}") do
      collectd_resource.variables[:collectd_config].packages.delete(new_resource.package_name)
    end
  end
end
