# frozen_string_literal: true
include ResourceType
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists && @current_resource.included
    Chef::Log.info "#{@new_resource} already exists and is included - nothing to do."
  elsif @current_resource.exists
    Chef::Log.debug "#{@new_resource} already exists - but not included."
    converge_by("Include #{@new_resource}") do
      include_resource_type
    end
  else
    converge_by("Create #{@new_resource}") do
      create_resource_type
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsResourceType.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = rt_exists?(node['opennms']['conf']['home'], @current_resource.name)
  @current_resource.included = rt_included?(node['opennms']['conf']['home'], @current_resource.name)
end

private

# resource type doesn't exist and isn't included. Group could exist, though.
def create_resource_type
  Chef::Log.debug "Adding resource type: '#{new_resource.name}'"
  outfile_name = "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml"
  doc = nil
  group_el = nil
  file_name = find_group(node['opennms']['conf']['home'], new_resource.group_name)
  # deal with the group existing but not the resource type
  if !file_name.nil?
    outfile_name = file_name
    # file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml", "r")
    file = ::File.new(file_name, 'r')
    doc = REXML::Document.new file
    doc.context[:attribute_quote] = :quote
    file.close
    group_el = doc.elements["/datacollection-group[@name='#{new_resource.group_name}']"]
  else
    doc = REXML::Document.new
    doc.context[:attribute_quote] = :quote
    doc << REXML::XMLDecl.new
    group_el = doc.add_element 'datacollection-group', 'name' => new_resource.group_name
  end
  type_el = group_el.add_element 'resourceType', 'name' => new_resource.name, 'label' => new_resource.label
  if new_resource.resource_label
    type_el.add_attribute('resourceLabel', new_resource.resource_label)
  end
  persist_el = type_el.add_element 'persistenceSelectorStrategy', 'class' => new_resource.persistence_selector_strategy
  new_resource.persistence_selector_strategy_params.each do |param|
    persist_el.add_element 'parameter', 'key' => param.keys[0], 'value' =>  param[param.keys[0]]
  end
  storage_el = type_el.add_element 'storageStrategy', 'class' => new_resource.storage_strategy
  new_resource.storage_strategy_params.each do |param|
    storage_el.add_element 'parameter', 'key' => param.keys[0], 'value' =>  param[param.keys[0]]
  end

  Opennms::Helpers.write_xml_file(doc, outfile_name)
  # ensure there's an include-collection element in the default snmp-collection for this group
  opennms_snmp_collection_group new_resource.group_name do
    collection_name 'default'
  end
  file "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml" do
    action :touch
  end
end

def include_resource_type
  # find the group name the resource_type exists in
  group_name = find_resource_type(node['opennms']['conf']['home'], new_resource.name)
  # add the group to the default snmp-collection
  opennms_snmp_collection_group group_name do
    collection_name 'default'
  end
end
