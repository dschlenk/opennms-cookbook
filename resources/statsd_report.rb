include Opennms::XmlHelper
include Opennms::Cookbook::Statsd::StatsdTemplate

property :report_name, String, name_property: true
property :package_name, String, required: true, identity: true
# required for new
property :description, String
# default for new is daily at 01:20:00
property :schedule, String
# default for new to 30 days
property :retain_interval, Integer
# default for new is 'on'
property :status, String, equal_to: %w(on off)
# key/value string pairs
property :parameters, Hash, callbacks: {
  'should be a Hash with String key and values' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}
# default for new is 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor'
# other known option is same package, but class 'BottomNAttributeStatisticVisitor'
property :class_name, String, equal_to: %w(org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor)

load_current_value do |new_resource|
  config = statsd_resource.variables[:config] unless statsd_resource.nil?
  config = Opennms::Cookbook::Statsd::StatsdConfiguration.read("#{onms_etc}/statsd-configuration.xml") if config.nil?
  package = config.package(name: new_resource.package_name)
  current_value_does_not_exist! if package.nil?
  report = package.report(name: new_resource.report_name)
  current_value_does_not_exist! if report.nil?
  %i(description schedule retain_interval status parameters class_name).each do |p|
    send(p, report.send(p))
  end
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
    raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} found. Use the `opennms_statsd_package` resource to create one." if package.nil?
    report = package.report(name: new_resource.report_name)
    if report.nil?
      raise Chef::Exceptions::ValidationFailed, 'Property `description` is required for new reports' if new_resource.description.nil?
      package.add_report(name: new_resource.report_name, description: new_resource.description, schedule: new_resource.schedule || '0 20 1 * * ?', retain_interval: new_resource.retain_interval || 2_592_000_000, status: new_resource.status || 'on', parameters: new_resource.parameters, class_name: new_resource.class_name || 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor')
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  report = package.report(name: new_resource.report_name)
  run_action(:create) if report.nil?
end

action :update do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  raise Chef::Exceptions::ResourceNotFound, "No package named #{new_resource.package_name} found. Use the `opennms_statsd_package` resource to create one." if package.nil?
  report = package.report(name: new_resource.report_name)
  raise Chef::Exceptions::ResourceNotFound, "No report named #{new_resource.report_name} found in package #{new_resource.package_name} to update. Use actions `:create` or `:create_if_missing` to create a new report in package #{new_resource.package_name}." if report.nil?
  converge_if_changed do
    rp = %i(description schedule retain_interval status parameters class_name).map { |p| [p, new_resource.send(p)] }.to_h.compact
    report.update(**rp)
  end
end

action :delete do
  statsd_resource_init
  config = statsd_resource.variables[:config]
  package = config.package(name: new_resource.package_name)
  report = package.report(name: new_resource.report_name) unless package.nil?
  converge_by "Removing report #{new_resource.report_name} from statsd package #{new_resource.package_name}." do
    package.delete_report(name: new_resource.report_name)
  end unless report.nil?
end
