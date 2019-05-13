# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - updating collection files as necessary."
    updated = false
    unless new_resource.file.nil?
      f = cookbook_file new_resource.file do
        path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
        owner 'root'
        group 'root'
        mode 00644
      end
      updated = f.updated_by_last_action?
    end
    if updated
      converge_by("Update #{@new_resource}") do
        restart_collectd
      end
    end
  else
    converge_by("Create #{@new_resource}") do
      create_snmp_collection_group
    end
  end
end

action :delete do
	if @current_resource.exists
		converge_by("Deleting #{@new_resource}") do
			delete_snmp_collection_group
		end
	else
		Chef::Log.info("#{@new_resource} does not exist - nothing to do.")
	end
end


def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_snmp_collection_group, node).new(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  # Good enough for create but that's about it
  if group_exists?(@current_resource.collection_name, @current_resource.name)
    @current_resource.exists = true
  end
end

private

def group_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this snmp collection group exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/datacollection-config/snmp-collection[@name='#{collection_name}']/include-collection[@dataCollectionGroup='#{name}']"].nil?
end

def create_snmp_collection_group
  Chef::Log.debug "Adding snmp collection group: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  collection_el = doc.elements["/datacollection-config/snmp-collection[@name='#{new_resource.collection_name}']"]
  include_collection_el = collection_el.add_element 'include-collection', 'dataCollectionGroup' => new_resource.name
  unless new_resource.system_def.nil?
    include_collection_el.add_attribute('systemDef', new_resource.system_def)
  end
  new_resource.exclude_filters.each do |exclude_filter|
    exclude_filter_el = include_collection_el.add_element 'exclude-filter'
    exclude_filter_el.add_text(REXML::CData.new(exclude_filter))
  end
  dcfile = new_resource.file || 'foo'
  cookbook_file "#{dcfile}_#{new_resource.name}" do
    source dcfile
    path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
    owner 'root'
    group 'root'
    mode 00644
    not_if { new_resource.file.nil? }
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
end

def restart_collectd
  file "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml" do
    action :touch
  end
end

def delete_snmp_collection_group
	group_name = new_resource.collection_name || new_resource.name
	Chef::Log.debug "Deleting snmp collection group : '#{group_name}'"
	
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", 'r')
	contents = file.read
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	snmp_collection_group_el = snmp_collection_group_el(doc, new_resource, true)
	Chef::Log.debug("element deleted is #{snmp_collection_group_el}")
	Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml")
end

def snmp_collection_group_el(doc, resource, delete = false)
	group_name = resource.collection_name || resource.name
	collection_el = doc.elements["/datacollection-config/snmp-collection[@name='#{resource.collection_name}']"]
	include_collection_el = collection_el.add_element 'include-collection', 'dataCollectionGroup' => resource.name
	
	if group_exists?(resource.collection_name, resource.name)
		Chef::Log.debug("found? #{include_collection_el}")
		doc.root.elements.delete(include_collection_el) if !include_collection_el.nil? && delete
	end
	include_collection_el
end