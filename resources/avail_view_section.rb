include Opennms::XmlHelper
include Opennms::Cookbook::Rtc::AvailViewSection
property :section, String, name_property: true
# containing view-name, default is the default OpenNMS ships with
property :view_name, String, default: 'WebConsoleView', identity: true
property :category_group, String, deprecated: 'The category_group property is no longer used and will be removed in a future release.'
property :categories, Array
# controls where to position new view sections.
# Only affects new resources; doesn't move existing view sections.
# It's an error to define all three of these properties. If more than one
# are defined, the precendence is:
# before
# after
# position
property :before, String, desired_state: false # name of a view section to place the new section before
property :after, String, desired_state: false # name of a view section to place the new section after
# append or prepend this view section to the current sections list
property :position, String, desired_state: false, equal_to: %w(top bottom), default: 'top'

load_current_value do |new_resource|
  views = vd_resource.variables[:views] unless vd_resource.nil?
  if views.nil?
    ro_vd_resource_init
    views = ro_vd_resource.variables[:views]
  end
  view = views[new_resource.view_name]
  current_value_does_not_exist! if view.nil?
  section = view.section(section: new_resource.section)
  current_value_does_not_exist! if section.nil?
  categories section['categories']
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Rtc::AvailViewSection
end

action :create do
  raise Chef::Exceptions::ValidationFailed, 'Only one of properties `:before` and `:after` can be specified on the same resource.' if !new_resource.before.nil? && !new_resource.after.nil?
  converge_if_changed do
    vd_resource_init
    views = vd_resource.variables[:views]
    view = views[new_resource.view_name]
    raise Chef::Exceptions::ValidationFailed, "No view named #{new_resource.view_name} found. Cannot add section #{new_resource.section} to a non-existant view." if view.nil?
    section = view.section(section: new_resource.section)
    if section.nil?
      view.add_section(section: new_resource.section, categories: new_resource.categories, before: new_resource.before, after: new_resource.after, position: new_resource.position)
    else
      section['categories'] = new_resource.categories unless new_resource.categories.nil?
    end
  end
end

action :create_if_missing do
  raise Chef::Exceptions::ValidationFailed, 'Only one of properties `:before` and `:after` can be specified on the same resource.' if !new_resource.before.nil? && !new_resource.after.nil?
  vd_resource_init
  views = vd_resource.variables[:views]
  view = views[new_resource.view_name]
  raise Chef::Exceptions::ValidationFailed, "No view named #{new_resource.view_name} found. Cannot add section #{new_resource.section} to a non-existant view." if view.nil?
  section = view.section(section: new_resource.section)
  run_action(:create) if section.nil?
end

action :update do
  vd_resource_init
  views = vd_resource.variables[:views]
  view = views[new_resource.view_name]
  raise Chef::Exceptions::ValidationFailed, "No view named #{new_resource.view_name} found. Cannot add section #{new_resource.section} to a non-existant view." if view.nil?
  section = view.section(section: new_resource.section)
  raise Chef::Exceptions::ResourceNotFound, "No existing section named #{new_resource.section} found in view #{new_resource.view_name} to update. Use action `:create` or `:create_if_missing` to make a new section." if section.nil?
  run_action(:create)
end

action :delete do
  vd_resource_init
  views = vd_resource.variables[:views]
  view = views[new_resource.view_name]
  raise Chef::Exceptions::ValidationFailed, "No view named #{new_resource.view_name} found. Cannot add section #{new_resource.section} to a non-existant view." if view.nil?
  section = view.section(section: new_resource.section)
  converge_by "Removing section #{new_resource.section} from view #{new_resource.view_name}." do
    view.delete_section(section: new_resource.section)
  end unless section.nil?
end
