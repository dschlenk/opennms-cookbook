# the user or group to notify
property :target_name, String, name_property: true
# the name of the destination path that this target belongs to
property :destination_path_name, String, required: true, identity: true
# optional for update; at least one member is required for new
property :commands, Array, callbacks: {
  'should be an Array of strings with at least one member' => lambda { |p|
    !p.empty? && !p.any? { |a| !a.is_a?(String) }
  },
}
# determines if off duty targets get notifications for automatically acknowledged notifications
property :auto_notify, String, equal_to: %w(on off auto)
# when target_name is a group, the amount of time to wait between notifying members of the group
property :interval, String
# whether this is a target or escalation target. Targets are sent after the initial delay whereas escalation targets are sent in order waiting the same escalate_delay period between each.
property :type, String, equal_to: %w(target escalate), default: 'target', identity: true
# only valid for escalation targets
property :escalate_delay, String

include Opennms::XmlHelper
include Opennms::Cookbook::Notification::DestinationPathsTemplate
load_current_value do |new_resource|
  config = dp_resource.variables[:config] unless dp_resource.nil?
  if config.nil?
    ro_dp_resource_init
    config = ro_dp_resource.variables[:config]
  end
  path = config.path(path_name: new_resource.destination_path_name)
  current_value_does_not_exist! if path.nil?
  value = if new_resource.type.eql?('escalate')
            path.escalate(escalate_name: new_resource.target_name)
          else
            path.target(target_name: new_resource.target_name)
          end
  current_value_does_not_exist! if value.nil?
  %i(commands auto_notify interval).each do |p|
    send(p, value.send(p))
  end
  escalate_delay value.delay if new_resource.type.eql?('escalate')
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Notification::DestinationPathsTemplate
end

action :create do
  converge_if_changed do
    dp_resource_init
    config = dp_resource.variables[:config]
    path = config.path(path_name: new_resource.destination_path_name)
    raise Chef::Exceptions::ResourceNotFound, "Cannot add target to destination path #{new_resource.destination_path_name} as it does not exist. Use the `opennms_destination_path` resource to create one." if path.nil?
    value = if new_resource.type.eql?('escalate')
              path.escalate(escalate_name: new_resource.target_name)
            else
              path.target(target_name: new_resource.target_name)
            end
    rp = %i(commands auto_notify interval).map { |p| [p, new_resource.send(p)] }.to_h
    rp[:delay] = new_resource.escalate_delay if new_resource.type.eql?('escalate')
    if value.nil?
      rp[:name] = new_resource.target_name
      raise Chef::Exceptions::ValidationFailed, 'Property `commands` must contain at least one member when adding a new target.' if new_resource.commands.nil?
      if new_resource.type.eql?('escalate')
        path.escalates.push(Opennms::Cookbook::Notification::Escalate.new(**rp))
      else
        path.targets.push(Opennms::Cookbook::Notification::Target.new(**rp))
      end
    else
      value.update(**rp)
    end
  end
end

action :create_if_missing do
  dp_resource_init
  config = dp_resource.variables[:config]
  path = config.path(path_name: new_resource.destination_path_name)
  raise Chef::Exceptions::ResourceNotFound, "Cannot add #{new_resource.type} to destination path #{new_resource.destination_path_name} as it does not exist. Use the `opennms_destination_path` resource to create one." if path.nil?
  value = if new_resource.type.eql?('escalate')
            path.escalate(escalate_name: new_resource.target_name)
          else
            path.target(target_name: new_resource.target_name)
          end
  run_action(:create) if value.nil?
end

action :update do
  dp_resource_init
  config = dp_resource.variables[:config]
  path = config.path(path_name: new_resource.destination_path_name)
  raise Chef::Exceptions::ResourceNotFound, "Cannot add #{new_resource.type} to destination path #{new_resource.destination_path_name} as it does not exist. Use the `opennms_destination_path` resource to create one." if path.nil?
  value = if new_resource.type.eql?('escalate')
            path.escalate(escalate_name: new_resource.target_name)
          else
            path.target(target_name: new_resource.target_name)
          end
  raise Chef::Exceptions::ResourceNotFound, "No existing #{new_resource.type} named #{new_resource.target_name} in destination path #{new_resource.destination_path_name} found. Use the `:create` or `:create_if_missing` actions to create one." if value.nil?
  run_action(:create)
end

action :delete do
  dp_resource_init
  config = dp_resource.variables[:config]
  path = config.path(path_name: new_resource.destination_path_name)
  unless path.nil?
    value = if new_resource.type.eql?('escalate')
              path.escalate(escalate_name: new_resource.target_name)
            else
              path.target(target_name: new_resource.target_name)
            end
    converge_by "Removing #{new_resource.type} #{new_resource.target_name} from destination path #{new_resource.destination_path_name}." do
      if new_resource.type.eql?('escalate')
        path.delete_escalate(escalate_name: new_resource.target_name)
      else
        path.delete_target(target_name: new_resource.target_name)
      end
    end unless value.nil?
  end
end
