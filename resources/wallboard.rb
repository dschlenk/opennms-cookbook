include Opennms::XmlHelper
include Opennms::Cookbook::View::WallboardTemplate
property :title, String, name_property: true
property :set_default, [true, false]

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::View::WallboardTemplate
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/dashboard-config.xml")
  config = wallboard_resource.variables[:config] unless wallboard_resource.nil?
  config = Opennms::Cookbook::View::DashboardConfig.read("#{onms_etc}/dashboard-config.xml") if config.nil?
  wallboard = config.wallboard(title: new_resource.title)
  current_value_does_not_exist! if wallboard.nil?
  # since set_default is not required, but it becomes false when not otherwise specified, only consider set_default if new_resource specifies it
  if [true, false].include?(new_resource.set_default)
    if config.default_wallboard.eql?(new_resource.title)
      set_default true
    else
      set_default false
    end
  end
end

action :create do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.title)
    if wallboard.nil?
      config.wallboards.push({ 'title' => new_resource.title })
      config.default_wallboard = new_resource.title if new_resource.set_default
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.title)
    raise Chef::Exceptions::ResourceNotFound, "No wallboard named #{new_resource.title} found. Use action `:create` or `:create_if_missing` to make a new wallboard." if wallboard.nil?
    config.default_wallboard = new_resource.title if new_resource.set_default
  end
end

action :create_if_missing do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.title)
    run_action(:create) if wallboard.nil?
  end
end

action :delete do
  wallboard_resource_init
  config = wallboard_resource.variables[:config]
  wallboard = config.wallboard(title: new_resource.title)
  converge_by "Removing wallboard #{new_resource.title}" do
    config.wallboards.delete_if { |w| w['title'].eql?(new_resource.title) }
  end unless wallboard.nil?
end
