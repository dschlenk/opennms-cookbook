include Opennms::XmlHelper
include Opennms::Cookbook::Poller::PollerTemplate

use 'partial/_package'
unified_mode true

# default to false on :create
property :remote, [true, false]
# default to 300 on :create
property :rrd_step, Integer
# default to ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] on :create
property :rras, Array
# BEGIN => {'interval' => 00000, 'end' => 00000, 'delete' => true}, ...
# default to { 0 => { 'interval' => 30_000, 'end' => 300_000 }, 300_000 => { 'interval' => 300_000, 'end' => 43_200_000 }, 43_200_000 => { 'interval' => 600_000, 'end' => 432_000_000 }, 432_000_000 => { 'delete' => true } } on :create
property :downtimes, Hash, callbacks: {
  'should be a hash with integer keys represeting the `begin` key with a hash value containing `interval` and (optional) `end` keys both with integer values' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(Integer) || !v.is_a?(Hash) || !v.key?('interval') || !v['interval'].is_a?(Integer) || (v.key?('end') && !v['end'].is_a?(Integer)) }
  },
}

action_class do
  include Opennms::Cookbook::Poller::PollerTemplate
end

load_current_value do |new_resource|
  config = poller_resource.variables[:config] unless poller_resource.nil?
  config = Opennms::Cookbook::Package::PollerConfigFile.read("#{onms_etc}/poller-configuration.xml") if config.nil?
  package = config.packages[new_resource.package_name] unless config.nil?
  current_value_does_not_exist! if package.nil?
  %i(filter specifics include_ranges exclude_ranges include_urls outage_calendars remote rrd_step rras downtimes).each do |p|
    send(p, package.send(p))
  end
end

action :create do
  converge_if_changed do
    poller_resource_init
    package = poller_resource.variables[:config].packages[new_resource.package_name]
    if package.nil?
      rp = %i(package_name filter specifics include_ranges exclude_ranges include_urls outage_calendars remote rrd_step rras downtimes).map { |p| [p, new_resource.send(p)] }.to_h.compact
      poller_resource.variables[:config].packages[new_resource.package_name] = Opennms::Cookbook::Package::PollerPackage.new(**rp)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  poller_resource_init
  package = poller_resource.variables[:config].packages[new_resource.package_name]
  run_action(:create) if package.nil?
end

action :update do
  converge_if_changed do
    poller_resource_init
    config = poller_resource.variables[:config]
    package = config.packages[new_resource.package_name]
    raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} found to update. Use the `:create` action to make a new package" if package.nil?
    package.update(filter: new_resource.filter, specifics: new_resource.specifics, include_ranges: new_resource.include_ranges, exclude_ranges: new_resource.exclude_ranges, include_urls: new_resource.include_urls, outage_calendars: new_resource.outage_calendars, remote: new_resource.remote, rrd_step: new_resource.rrd_step, rras: new_resource.rras, downtimes: new_resource.downtimes)
  end
end

action :delete do
  poller_resource_init
  config = poller_resource.variables[:config]
  package = config.packages[new_resource.package_name]
  unless package.nil?
    converge_by "Removing poller package #{new_resource.package_name}" do
      config.packages.delete(new_resource.package_name)
    end
  end
end
