include Opennms::XmlHelper
include Opennms::Cookbook::View::SurveillanceTemplate
# rows and columns should be of the form
# { 'Category Label' => ['categoryName', ...], ... }
# at least one of each is required
# but are optional to support updates
property :rows, Hash, callbacks: {
  'should be a hash with at least one member having String keys that have Array of String values' => lambda { |p|
    p.length > 0 && !p.any? { |k,v| !k.is_a?(String) || !v.is_a?(Array) || v.any? { |a| !a.is_a?(String) } }
  }
}
property :columns, Hash, callbacks: {
  'should be a hash with at least one member having String keys that have Array of String values' => lambda { |p|
    p.length > 0 && !p.any? { |k,v| !k.is_a?(String) || !v.is_a?(Array) || v.any? { |a| !a.is_a?(String) } }
  }
}
# defaults to false on initial :create
property :default_view, [true, false]
property :refresh_seconds, [Integer, String]

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::View::SurveillanceTemplate
end

load_current_value do |new_resource|
  config = view_resource.variables[:config] unless view_resource.nil?
  config = Opennms::Cookbook::View::SurveillanceConfig.read("#{onms_etc}/surveillance-views.xml") if config.nil?
  current_value_does_not_exist! if config.nil?
  view = config.views[new_resource.name]
  current_value_does_not_exist! if view.nil?
  rows view['rows']
  columns view['columns']
  refresh_seconds view['refresh-seconds']
  default_view true if config.default_view.eql?(new_resource.name)
  default_view false if new_resource.default_view.eql?(false) && !config.default_view.eql?(new_resource.name)
end

action :create do
  converge_if_changed do
    view_resource_init
    config = view_resource.variables[:config]
    view = config.views[new_resource.name]
    if view.nil?
      raise Chef::Exceptions::Validation, "At least one row and column are required when creating a new surveillance view" if new_resource.rows.nil? || new_resource.rows.length < 1 || new_resource.columns.nil? || new_resource.columns.length < 1
      config.views[new_resource.name] = { 'name' => new_resource.name, 'rows' => new_resource.rows, 'columns' => new_resource.columns }
      config.views[new_resource.name]['refresh-seconds'] = new_resource.refresh_seconds unless new_resource.refresh_seconds.nil?
      config.default_view = new_resource.name if new_resource.default_view
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  view_resource_init
  config = view_resource.variables[:config]
  view = config.views[new_resource.name]
  run_action(:create) if view.nil?
end

action :update do
  converge_if_changed do
    view_resource_init
    config = view_resource.variables[:config]
    view = config.views[new_resource.name]
    raise Chef::Exceptions::ResourceNotFound, "No view named #{new_resource.name} found to update. Use action `:create` or `:create_if_missing` to add a new view." if view.nil?
    view['rows'] = new_resource.rows unless new_resource.rows.nil?
    view['columns'] = new_resource.columns unless new_resource.columns.nil?
    view['refresh-seconds'] = new_resource.refresh_seconds unless new_resource.refresh_seconds.nil?
    config.default_view = new_resource.name if new_resource.default_view
  end
end

action :delete do
  view_resource_init
  config = view_resource.variables[:config]
  view = config.views[new_resource.name]
  converge_by "Removing view #{new_resource.name}" do
    config.views.delete(new_resource.name)
    config.default_view = nil if config.default_view.eql?(new_resource.name)
  end unless view.nil?
end
