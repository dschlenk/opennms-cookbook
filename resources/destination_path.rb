include Opennms::XmlHelper
include Opennms::Cookbook::Notification::DestinationPathsTemplate
property :path_name, String, name_property: true
# defaults to '0s' on new
property :initial_delay, String

load_current_value do |new_resource|
  config = dp_resource.variables[:config] unless dp_resource.nil?
  if config.nil?
    ro_dp_resource_init
    config = ro_dp_resource.variables[:config]
  end
  path = config.path(path_name: new_resource.path_name)
  current_value_does_not_exist! if path.nil?
  initial_delay path.initial_delay
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Notification::DestinationPathsTemplate
end

action :create do
  converge_if_changed do
    dp_resource_init
    config = dp_resource.variables[:config]
    path = config.path(path_name: new_resource.path_name)
    if path.nil?
      config.paths.push(Opennms::Cookbook::Notification::DestinationPath.new(path_name: new_resource.path_name, initial_delay: new_resource.initial_delay || '0s'))
    else
      path.update(initial_delay: new_resource.initial_delay)
    end
  end
end

action :create_if_missing do
  dp_resource_init
  config = dp_resource.variables[:config]
  path = config.path(path_name: new_resource.path_name)
  if path.nil?
    run_action(:create)
  end
end

action :update do
  converge_if_changed do
    dp_resource_init
    config = dp_resource.variables[:config]
    path = config.path(path_name: new_resource.path_name)
    if path.nil?
      raise Chef::Exceptions::ResourceNotFound, "No destination path named #{new_resource.path_name} found to update. Use action `:create` or `:create_if_missing` to make a new destination path."
    else
      path.update(initial_delay: new_resource.initial_delay)
    end
  end
end

action :delete do
  dp_resource_init
  config = dp_resource.variables[:config]
  path = config.path(path_name: new_resource.path_name)
  unless path.nil?
    converge_by "Removing destination path #{new_resource.path_name}" do
      config.delete_path(path_name: new_resource.path_name)
    end
  end
end
