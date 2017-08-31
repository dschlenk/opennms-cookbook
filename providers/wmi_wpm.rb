# frozen_string_literal: true
include ResourceType
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing wmi-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  Chef::Application.fatal!("Missing resourceType #{@current_resource.resource_type}.") unless @current_resource.resource_type_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_wmi_wpm
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsWmiWpm.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.resource_type(@new_resource.resource_type)

  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
  end
  if wpm_exists?(@current_resource.collection_name, @current_resource.name)
    @current_resource.exists = true
  end
  if resource_type_exists?(@current_resource.resource_type)
    @current_resource.resource_type_exists = true
  end
end

private

def resource_type_exists?(resource_type)
  rt_exists?(node['opennms']['conf']['home'], resource_type) && rt_included?(node['opennms']['conf']['home'], resource_type)
end

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this wmi collection exists: '#{collection_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{collection_name}']"].nil?
end

def wpm_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this wmi wpm exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{collection_name}']/wpms/wpm[@name='#{name}']"].nil?
end

def create_wmi_wpm
  Chef::Log.debug "Creating wmi wpm : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  wpms_el = doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{new_resource.collection_name}']/wpms"]
  wpm_el = wpms_el.add_element 'wpm', 'name' => new_resource.name, 'wmiClass' => new_resource.wmi_class, 'keyvalue' => new_resource.keyvalue, 'recheckInterval' => new_resource.recheck_interval, 'ifType' => new_resource.if_type, 'resourceType' => new_resource.resource_type
  if new_resource.wmi_namespace
    wpm_el.add_attribute('wmiNamespace', new_resource.wmi_namespace)
  end
  new_resource.attribs.each do |name, details|
    attrib_el = wpm_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'wmiObject' => details['wmi_object'], 'type' => details['type']
    attrib_el.add_attribute('maxval', details['maxval']) if details['maxval']
    attrib_el.add_attribute('minval', details['minval']) if details['minval']
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml")
end
