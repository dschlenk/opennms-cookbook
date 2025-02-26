include Opennms::XmlHelper
include Opennms::Cookbook::View::WallboardTemplate

property :title, String, name_property: true
property :wallboard, String, required: true, identity: true
# 0 on initial :create
property :boost_duration, Integer
# 0 on initial :create
property :boost_priority, Integer
# 15 on initial :create
property :duration, Integer
# 5 on initial :create
property :priority, Integer
# not to be confused with the name of the resource aka title.
# this is actually the type of dashlet, but we'll follow the naming used in the XML file.
# required on initial :create
property :dashlet_name, String, equal_to: ['Surveillance', 'RTC', 'Summary', 'Alarm Details', 'Alarms', 'Charts', 'Image', 'KSC', 'Map', 'RRD', 'Topology', 'URL']
property :parameters, Hash, callbacks: {
  'should be a hash with String keys and String values' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/dashboard-config.xml")
  config = wallboard_resource.variables[:config] unless wallboard_resource.nil?
  config = Opennms::Cookbook::View::DashboardConfig.read("#{onms_etc}/dashboard-config.xml") if config.nil?
  wallboard = config.wallboard(title: new_resource.wallboard)
  current_value_does_not_exist! if wallboard.nil?
  dashlet = config.dashlet(wallboard: wallboard, title: new_resource.title)
  current_value_does_not_exist! if dashlet.nil?
  %i(boost_duration boost_priority duration priority dashlet_name parameters).each do |p|
    send(p, dashlet[p.to_s])
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::View::WallboardTemplate
end

action :create do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.wallboard)
    raise Chef::Exceptions::ResourceNotFound, "No wallboard with title #{new_resource.wallboard} found - cannot add a dashlet to it." if wallboard.nil?
    dashlet = config.dashlet(wallboard: wallboard, title: new_resource.title)
    if dashlet.nil? || dashlet.empty?
      raise Chef::Exceptions::ValidationFailed, 'Property dashlet_name is required for action :create' if new_resource.dashlet_name.nil?
      wallboard['dashlets'] = [] if wallboard['dashlets'].nil?
      wallboard['dashlets'].push({ 'title' => new_resource.title,
                                   'boost_duration' => new_resource.boost_duration || 0,
                                   'boost_priority' => new_resource.boost_priority || 0,
                                   'duration' => new_resource.duration || 15,
                                   'priority' => new_resource.priority || 5,
                                   'dashlet_name' => new_resource.dashlet_name,
                                   'parameters' => new_resource.parameters }.compact)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.wallboard)
    raise Chef::Exceptions::ResourceNotFound, "No wallboard with title #{new_resource.wallboard} found - cannot add a dashlet to it." if wallboard.nil?
    dashlet = config.dashlet(wallboard: wallboard, title: new_resource.title)
    if dashlet.nil?
      run_action(:create)
    end
  end
end

action :update do
  converge_if_changed do
    wallboard_resource_init
    config = wallboard_resource.variables[:config]
    wallboard = config.wallboard(title: new_resource.wallboard)
    raise Chef::Exceptions::ResourceNotFound, "No wallboard with title #{new_resource.wallboard} found." if wallboard.nil?
    dashlet = config.dashlet(wallboard: wallboard, title: new_resource.title)
    if dashlet.nil?
      raise Chef::Exceptions::ResourceNotFound, "No dashlet with title #{new_resource.title} found in wallboard #{new_resource.wallboard}. Must use action `:create` or `:create_if_missing` to create it before it can be updated."
    else
      %i(boost_duration boost_priority duration priority dashlet_name parameters).each do |p|
        dashlet[p.to_s] = new_resource.send(p) unless new_resource.send(p).nil?
      end
    end
  end
end

action :delete do
  wallboard_resource_init
  config = wallboard_resource.variables[:config]
  wallboard = config.wallboard(title: new_resource.wallboard)
  dashlet = config.dashlet(wallboard: wallboard, title: new_resource.title) unless wallboard.nil?
  converge_by "Removing dashlet #{new_resource.title}" do
    wallboard['dashlets'].delete_if { |d| d['title'].eql?(new_resource.title) }
  end unless dashlet.nil?
end
