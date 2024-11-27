include Opennms::XmlHelper
include Opennms::Cookbook::Threshold::ThresholdsTemplate
unified_mode true
property :group_name, String, name_property: true
# required for :create, but defaults to `$OPENNMS_HOME/share/rrd/snmp` when not provided
property :rrd_repository, String

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Threshold::ThresholdsTemplate
end

load_current_value do |new_resource|
  config = if thresholds_resource.nil?
             Opennms::Cookbook::Threshold::ThresholdsFile.read("#{onms_etc}/thresholds.xml")
           else
             thresholds_resource.variables[:config]
           end
  group = config.groups[new_resource.group_name]
  current_value_does_not_exist! if group.nil?
  rrd_repository group.rrd_repository
end

action :create do
  converge_if_changed do
    thresholds_resource_init
    config = thresholds_resource.variables[:config]
    group = config.groups[new_resource.group_name]
    if group.nil?
      config.groups[new_resource.group_name] = Opennms::Cookbook::Threshold::ThresholdGroup.new(name: new_resource.group_name, rrd_repository: new_resource.rrd_repository || "#{onms_share}/rrd/snmp")
    else
      run_action(:update)
    end
  end
end

action :update do
  thresholds_resource_init
  config = thresholds_resource.variables[:config]
  group = config.groups[new_resource.group_name]
  raise Chef::Exceptions::ResourceNotFound, "No group named #{new_resource.group_name} found. Use `:create` action to make a new group." if group.nil?
  converge_if_changed do
    group.rrd_repository = new_resource.rrd_repository unless new_resource.rrd_repository.nil?
  end
end

action :delete do
  thresholds_resource_init
  config = thresholds_resource.variables[:config]
  group = config.groups[new_resource.group_name]
  unless group.nil?
    converge_by "Removing threshold group #{new_resource.group_name}" do
      config.groups.delete(new_resource.group_name)
    end
  end
end
