# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jmx_collection
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJmxCollection.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if collection_exists?(@current_resource.name)
end

private

def collection_exists?(name)
  Chef::Log.debug "Checking to see if this jmx collection exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{name}']"].nil?
end

def create_jmx_collection
  Chef::Log.debug "Creating jmx collection : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  collection_el = doc.root.add_element 'jmx-collection', 'name' => new_resource.name
  rrd_el = collection_el.add_element 'rrd', 'step' => new_resource.rrd_step
  new_resource.rras.each do |rra|
    rra_el = rrd_el.add_element 'rra'
    rra_el.add_text(rra)
  end
  collection_el.add_element 'mbeans'

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml")
end
