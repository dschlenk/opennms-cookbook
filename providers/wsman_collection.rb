# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else converge_by("Create #{@new_resource}") do
    create_wsman_collection
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_collection, node).new(@new_resource.name)

  # Good enough for create/delete but that's about it
  @current_resource.exists = true if service_exists?(@current_resource.name)
end

private

def service_exists?(name)
  Chef::Log.debug "Checking to see if this wsman collection exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/wsman-datacollection-config/collection[@name='#{name}']"].nil?
end

def create_wsman_collection
  Chef::Log.debug "Creating wsman collection : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  collection_el = doc.root.add_element 'collection', 'name' => new_resource.name
  rrd_el = collection_el.add_element 'rrd', 'step' => new_resource.rrd_step
  new_resource.rras.each do |rra|
    rra_el = rrd_el.add_element 'rra'
    rra_el.add_text(rra)
  end

  unless new_resource.include_system_definitions.nil?
    unless new_resource.include_system_definitions == true
      collection_el.add_element 'include-system-definitions'
    end
  end

  unless new_resource.include_system_definition.nil?
    new_resource.include_system_definition.each do |name|
      collection_el.add_element 'include-system-definition' => name
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml")
end
