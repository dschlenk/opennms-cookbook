# Identity is determined by all properties.
attribute :role_name, kind_of: String, required: true, identity: true
attribute :username, kind_of: String, required: true, identity: true
attribute :type, kind_of: String, equal_to: %w(specific daily weekly monthly), required: true, identity: true
# Array of hashes with the keys:
# begins, ends: either dd-MMM-yyyy HH:mm:ss or HH:mm:ss
# day: optional and must match the pattern (monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])
# The value of this is validated before convergence is attempted.
attribute :times, kind_of: Array, required: true, identity: true

action_class do
  include Opennms::Rbac
end

action :create do
  raise Chef::Exceptions::ValidationFailed, "Missing role  #{new_resource.role_name}." unless role_exists?(new_resource.role_name)
  raise Chef::Exceptions::ValidationFailed, "User #{new_resource.username} not in role." unless user_in_group?(group_for_role(new_resource.role_name), new_resource.username)
  raise Chef::Exceptions::ValidationFailed, "Times array not valid #{new_resource.times}. See resource documentation for required format." unless times_valid?(new_resource.times)
  converge_if_changed do
    unless schedule_exists?(new_resource)
      add_schedule_to_role(new_resource)
    end
  end
end

action :delete do
  converge_by "Removing schedule for role #{new_resource.role_name} for user #{new_resource.username} of type #{new_resource.type} with times #{new_resource.times}" do
    delete_role_schedule(new_resource)
  end if schedule_exists?(new_resource)
end
