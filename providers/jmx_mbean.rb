# frozen_string_literal: true

action :create do
  raise("Missing jmx-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jmx_mbean
    end
  end
end

action :delete do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - deleting."
    converge_by("Delete #{@new_resource}") do
      delete_jmx_mbean
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_jmx_mbean, node).new(@new_resource.name)
  @current_resource.mbean_name(@new_resource.mbean_name || @new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.objectname(@new_resource.objectname)

  if mbean_exists?(@current_resource.mbean_name, @current_resource.collection_name, @current_resource.objectname)
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

def mbean_exists?(name, collection_name, objectname)
  Chef::Log.debug "Checking to see if this jmx mbean exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{collection_name}']/mbeans/mbean[@name='#{name}' and @objectname = '#{objectname}']"].nil?
end

def create_jmx_mbean
  mbean_name = new_resource.mbean_name || new_resource.name
  Chef::Log.debug "Creating jmx query : '#{mbean_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  mbeans_el = doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{new_resource.collection_name}']/mbeans"]
  unless mbeans_el.nil?
    mbean_el = mbeans_el.add_element 'mbean', 'name' => mbean_name, 'objectname' => new_resource.objectname
    new_resource.attribs.each do |name, details|
      mbean_el.add_element 'attrib', 'name' => name, 'type' => details['type'], 'alias' => details['alias']
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml")
end

def delete_jmx_mbean
  mbean_name = new_resource.mbean_name || new_resource.name
  Chef::Log.debug "Creating jmx query : '#{mbean_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  doc.elements.delete("/jmx-datacollection-config/jmx-collection[@name='#{new_resource.collection_name}']/mbeans/mbean[@name = '#{mbean_name}' and @objectname = '#{new_resource.objectname}']")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/jmx-datacollection-config.xml")
end
