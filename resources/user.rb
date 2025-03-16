include Opennms::Rbac
property :user_id, String, name_property: true
property :full_name, String
property :user_comments, String
# required for new, ignored for update unless action is :set_password
property :password, String
property :password_salt, [true, false], default: true
property :email, String
# Array of Strings
property :duty_schedules, Array, callbacks: {
  'should be an array of Strings' => lambda { |p|
    (p.one? && p[0].nil?) || !p.any? { |a| !a.is_a?(String) }
  },
}
# defaults to ['ROLE_USER'] on new
property :roles, Array, callbacks: {
  'should be an array of Strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}

action_class do
  include Opennms::Rbac
end

load_current_value do |new_resource|
  u = get_user(new_resource.user_id)
  current_value_does_not_exist! if u.nil?
  full_name u['full-name']
  email u['email']
  user_comments u['user-comments']
  # ignore password for updates
  password new_resource.password
  password_salt new_resource.password_salt
  roles u['role']
  duty_schedules u['duty-schedule']
end

action :create do
  u = get_user(new_resource.user_id)
  if u.nil?
    raise Chef::Exceptions::Validation, 'Password is required for action :create' if new_resource.password.nil?
    converge_if_changed do
      add_user(new_resource)
    end
  else
    run_action(:update)
  end
end

action :create_if_missing do
  u = get_user(new_resource.user_id)
  run_action(:create) if u.nil?
end

action :update do
  u = get_xml_user(new_resource.user_id)
  if !new_resource.full_name.nil? || !new_resource.email.nil? || !new_resource.user_comments.nil? || !new_resource.roles.nil? || !new_resource.duty_schedules.nil?
    converge_if_changed do
      raise Chef::Exceptions::ResourceNotFound, "No user with ID #{new_resource.user_id} found to updated. Use the `:create` action to make a new user." if u.nil?
      update_field(u.root, new_resource, :full_name, 'full-name') unless new_resource.full_name.nil?
      update_field(u.root, new_resource, :email, 'email') unless new_resource.email.nil?
      update_field(u.root, new_resource, :user_comments, 'user-comments') unless new_resource.user_comments.nil?
      unless new_resource.roles.nil?
        u.root.elements.delete_all('role')
        new_resource.roles.each do |r|
          u.root.add_element('role').text = r
        end
      end
      unless new_resource.duty_schedules.nil?
        u.root.elements.delete_all('duty-schedule')
        new_resource.duty_schedules.each do |d|
          u.root.add_element('duty-schedule').text = d
        end
      end
      update_user(u)
    end
  end
end

action :set_password do
  u = {}
  raise Chef::Exceptions::ResourceNotFound, "No user with ID #{new_resource.user_id} found to set password. Use the `:create` action to make a new user." if u.nil?
  converge_by "Set password for #{new_resource.user_id}" do
    u['password'] = new_resource.password
    u['passwordSalt'] = new_resource.password_salt
    update_password(new_resource.user_id, u)
  end
end

action :delete do
  u = get_user(new_resource.user_id)
  converge_by "Removing user #{new_resource.user_id}" do
    delete_user(new_resource.user_id)
  end unless u.nil?
end
