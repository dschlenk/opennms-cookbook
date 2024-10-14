unified_mode true
property :label,String, name_attribute: true
# containing CategoryGroup, default is the default OpenNMS ships with.
# It has to exist, although no custom resource to do so exists (yet)
property :category_group, String, default: 'WebConsole', identity: true
property :comment, String
property :normal, Float, default: 99.99
property :warning, Float, default: 97.0
property :rule, String, default: "IPADDR != '0.0.0.0'"
# array of Strings of services in poller or collectd
property :services, Array, default: []

action_class do
  include Opennms::Cookbook::ConfigHelpers::AvailCategory::AvailCategoryTemplate
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/categories.xml")
  doc = doc_from_file("#{onms_etc}/categories")
  current_value_does_not_exist! if doc.elements["/catinfo/categorygroup/name[text()[contains(.,'#{new_resource.category_group}')]]"].nil?
  cl = doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{new_resource.category_group}')]]]/categories/category/label[text()[contains(.,'#{new_resource.label}')]]"]
  current_value_does_not_Exist! if cl.nil?
  comment xml_element_text(cl, 'comment') unless xml_element_text(cl, 'comment').nil?
  normal xml_element_text(cl, 'normal') unless xml_element_text(cl, 'normal').nil?
  warning xml_element_text(cl, 'warning') unless xml_element_text(cl, 'warning').nil?
  rule xml_element_text(cl, 'rule') unless xml_element_text(cl, 'rule').nil?
  services xml_text_array(cl, 'service') unless cl.elements['service'].nil?
end

action :create do
  converge_if_changed do
    ac_resource_init
    cg = ac_resource.variables[:category_groups].category_group(new_resource.category_group)
    raise Opennms::Cookbook::ConfigHelpers::AvailCategory::CategoryGroupNotFound, "No such category group #{new_resource.category_group} exists" if cg.nil?
    c = cg.category(new_resource.label)
    if c.nil?
      resource_properties = %i(label comment normal warning rule services).map { |p| [p, new_resource.send(p)] }.to_h.compact
      c = Category.new(**resource_properties)
      cg.add(c)
    else
      run_action(:update)
    end
  end
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
