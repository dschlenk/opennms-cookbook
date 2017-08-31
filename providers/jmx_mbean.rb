# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing jmx-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jmx_mbean
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJmxMbean.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  if mbean_exists?(@current_resource.name, @current_resource.collection_name)
    @current_resource.exists = true
  end
  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
  end
end

private

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this jmx collection exists: '#{collection_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{collection_name}']"].nil?
end

def mbean_exists?(name, collection_name)
  Chef::Log.debug "Checking to see if this jmx mbean exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{collection_name}']/mbeans/mbean[@name='#{name}']"].nil?
end

def create_jmx_mbean
  Chef::Log.debug "Creating jmx query : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  mbeans_el = doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{new_resource.collection_name}']/mbeans"]
  unless mbeans_el.nil?
    mbean_el = mbeans_el.add_element 'mbean', 'name' => new_resource.name, 'objectname' => new_resource.objectname
    new_resource.attribs.each do |name, details|
      mbean_el.add_element 'attrib', 'name' => name, 'type' => details['type'], 'alias' => details['alias']
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml")
end
