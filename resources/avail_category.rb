include Opennms::XmlHelper
unified_mode true
property :label, String, name_property: true
# containing CategoryGroup, default is the default OpenNMS ships with.
# It has to exist, although no custom resource to do so exists (yet)
property :category_group, String, default: 'WebConsole', identity: true
property :comment, String
property :normal, Float # defaults: 99.99 on create
property :warning, Float # defaults: 97.0 on create
property :rule, String # default: "IPADDR != '0.0.0.0'" on create
# array of Strings of services in poller or collectd
property :services, Array # at least one required on create

action_class do
  include Opennms::Cookbook::ConfigHelpers::AvailCategory::AvailCategoryTemplate
  include Opennms::XmlHelper
end

include Opennms::Cookbook::ConfigHelpers::AvailCategory::AvailCategoryTemplate

load_current_value do |new_resource|
  r = ac_resource
  if r.nil?
    ro_ac_resource_init
    r = ro_ac_resource
  end
  cg = r.variables[:category_groups].category_group(new_resource.category_group)
  current_value_does_not_exist! if cg.nil?
  c = cg.category(new_resource.label)
  current_value_does_not_exist! if c.nil?
  comment c.comment
  normal c.normal.to_f
  warning c.warning.to_f
  rule c.rule
  services c.services
end

action :create do
  converge_if_changed do
    ac_resource_init
    cg = ac_resource.variables[:category_groups].category_group(new_resource.category_group)
    raise Opennms::Cookbook::ConfigHelpers::AvailCategory::CategoryGroupNotFound, "No such category group #{new_resource.category_group} exists" if cg.nil?
    c = cg.category(new_resource.label)
    if c.nil?
      raise Opennms::Cookbook::ConfigHelpers::AvailCategory::NoServices, "At least one service must be defined per category, but no services defined with category #{new_resource.label} in group #{new_resource.category_group}" if new_resource.services.nil? || new_resource.services.empty?
      resource_properties = %i(label comment normal warning rule services).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:normal] = 99.99 if resource_properties[:normal].nil?
      resource_properties[:warning] = 97.0 if resource_properties[:warning].nil?
      resource_properties[:rule] = 'IPADDR != \'0.0.0.0\'' if resource_properties[:rule].nil?
      c = Opennms::Cookbook::ConfigHelpers::AvailCategory::Category.new(**resource_properties)
      cg.add(c)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  ac_resource_init
  cg = ac_resource.variables[:category_groups].category_group(new_resource.category_group)
  raise Opennms::Cookbook::ConfigHelpers::AvailCategory::CategoryGroupNotFound, "No such category group #{new_resource.category_group} exists" if cg.nil?
  c = cg.category(new_resource.label)
  run_action(:create) if c.nil?
end

action :update do
  converge_if_changed(:comment, :normal, :warning, :rule, :services) do
    ac_resource_init
    c = ac_resource.variables[:category_groups].category(new_resource.category_group, new_resource.label)
    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update avail_category #{new_resource.label} in group #{new_resource.category_group} as it does not exist" if c.nil?
    c.update(comment: new_resource.comment, normal: new_resource.normal, warning: new_resource.warning, rule: new_resource.rule, services: new_resource.services)
  end
end

action :delete do
  ac_resource_init
  ac_resource.variables[:category_groups].delete(new_resource.category_group, new_resource.label)
end
