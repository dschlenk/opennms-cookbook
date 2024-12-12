property :group_name, String, name_property: true
property :default_svg_map, String, deprecated: 'the default-map option is deprecated and no longer used'
property :comments, String
# Array of strings. Users checked for existance
property :users, Array, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  }
}
# Array of strings - further validation not performed
property :duty_schedules, Array, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  }
}
include Opennms::Rbac
include Opennms::XmlHelper
load_current_value do |new_resource|
  current_value_does_not_exist! unless group_exists?(new_resource.group_name)
  group_el = group(new_resource.group_name)
  default_svg_map new_resource.default_svg_map # ignore since deprecated
  comments xml_element_text(group_el, 'comments')
  users xml_text_array(group_el, 'user')
  duty_schedules xml_text_array(group_el, 'duty-schedule')
end

action_class do
  include Opennms::Rbac
  include Opennms::XmlHelper
end

action :create do
  run_action :validate
  converge_if_changed do
    group_el = group(new_resource.group_name)
    if group_el.nil?
      add_group(new_resource)
    else
      run_action :update
    end
  end
end

action :validate do
  if !new_resource.users.nil?
    raise Chef::Exceptions::ValidationFailed, "Not all of the following users currently exist: #{new_resource.users.join(', ')}. Cannot create/update group #{new_resource.group_name}." unless users_exist?(new_resource.users)
  end
end

action :create_if_missing do
  run_action :validate
  group_el = group(new_resource.group_name)
  if group_el.nil?
    run_action :create
  end
end

action :update do
  run_action :validate
  converge_if_changed do
    group_el = group(new_resource.group_name)
    if group_el.nil?
      raise Chef::Exceptions::ResourceNotFound, "No group named #{new_resource.group_name} found to update. Use actions `:create` or `:create_if_missing` to create a group."
    else
      update_group(new_resource)
    end
  end
end

action :delete do
  group_el = group(new_resource.group_name)
  converge_by "Removing group #{new_resource.group_name}" do
    delete_group(new_resource.group_name)
  end unless group_el.nil?
end
