property :role_name, String, name_property: true
# required for new
property :membership_group, String
# required for new
property :supervisor, String
property :description, String

include Opennms::Rbac
load_current_value do |new_resource|
  current_value_does_not_exist! unless role_exists?(new_resource.role_name)
  role_el = role(new_resource.role_name)
  membership_group role_el.attributes['membership-group']
  supervisor role_el.attributes['supervisor']
  description role_el.attributes['description']
end

action_class do
  include Opennms::Rbac
end

action :create do
  raise Chef::Exceptions::ValidationFailed, "No group named #{new_resource.membership_group} found. Use the `opennms_group` resource to create one." unless group_exists?(new_resource.membership_group)
  raise Chef::Exceptions::ValidationFailed, "Cannot set `supervisor` to #{new_resource.supervisor} as user #{new_resource.supervisor} does not exist. Use the `opennms_user` resource to create one." unless user_exists?(new_resource.supervisor)
  converge_if_changed do
    if !role_exists?(new_resource.role_name)
      raise Chef::Exceptions::ValidationFailed, 'Properties `membership_group` and `supervisor` are required for action `:create` when the result is a new role.' if new_resource.membership_group.nil? || new_resource.supervisor.nil?
      add_role(new_resource)
    else
      run_action :update
    end
  end
end

action :create_if_missing do
  role_el = role(new_resource.role_name)
  run_action :create if role_el.nil?
end

action :update do
  raise Chef::Exceptions::ValidationFailed, "No role named #{new_resource.role_name} found. Use the `:create` or `:create_if_missing` action to create one." unless role_exists?(new_resource.role_name)
  converge_if_changed do
    update_role_attributes(new_resource)
  end
end

action :delete do
  converge_by "Removing role #{new_resource.role_name}" do
    delete_role(new_resource.role_name)
  end if role_exists?(new_resource.role_name)
end
