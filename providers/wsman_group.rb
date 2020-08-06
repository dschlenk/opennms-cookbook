# frozen_string_literal: true
include ResourceType
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_wsman_group
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.name)
  @current_resource.group_name(@new_resource.group_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)

  if group_exists?(@current_resource.group_name)
    @current_resource.group_exists = true
  end

  if resource_type_exists?(@current_resource.resource_type)
    @current_resource.resource_type_exists = true
  end
end

private

def resource_type_exists?(resource_type)
  rt_exists?(node['opennms']['conf']['home'], resource_type) && rt_included?(node['opennms']['conf']['home'], resource_type)
end

def group_exists?(group_name)
  Chef::Log.debug "Checking to see if this ws-man group exists: '#{group_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?
end

def create_wsman_group
  Chef::Log.debug "Creating wsman group : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  wsman_el = doc.elements["/wsman-datacollection-config/"]
  grooup_el = wsman_el.add_element 'group', 'name' => new_resource.name,'resource-uri' => new_resource.resource_uri, 'dialect' => new_resource.dialect,  'filter' => new_resource.filter, 'resource-type' => new_resource.resource_type

  new_resource.attribs.each do |name, details|
    attrib_el = grooup_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'filter' => details['filter'], 'type' => details['type'], 'type' => details['type'], 'index-of' => details['index-of']
    attrib_el.add_attribute('maxval', details['maxval']) if details['maxval']
    attrib_el.add_attribute('minval', details['minval']) if details['minval']
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml")
end

## TODO: only default to that file with the option to write to a specific file instead
## TODO: need to make sure you're adding groups in the right order - attempt to find instances of its siblings before / after and then insert appropriately