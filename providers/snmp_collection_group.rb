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
      f = if new_resource.source == 'cookbook_file'
            cookbook_file new_resource.file do
              path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
              owner 'root'
              group 'root'
              mode 00644
            end
          else
            remote_file new_resource.file do
              path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
              source new_resource.source
              owner 'root'
              group 'root'
              mode 00644
            end
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
    Chef::Log.info "#{@new_resource} does exists - deleting."
    converge_by("Delete #{@new_resource}") do
      delete_snmp_collection_group
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_snmp_collection_group, node).new(@new_resource.name)
  @current_resource.group_name(@new_resource.group_name || @new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  # Good enough for create / delete, but needs work if we implement support for changing existing
  if group_exists?(@current_resource.collection_name, @current_resource.group_name)
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
  group_name = new_resource.group_name || new_resource.name
  Chef::Log.debug "Adding snmp collection group: '#{group_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  collection_el = doc.elements["/datacollection-config/snmp-collection[@name='#{new_resource.collection_name}']"]
  include_collection_el = collection_el.add_element 'include-collection', 'dataCollectionGroup' => group_name
  unless new_resource.system_def.nil?
    include_collection_el.add_attribute('systemDef', new_resource.system_def)
  end
  new_resource.exclude_filters.each do |exclude_filter|
    exclude_filter_el = include_collection_el.add_element 'exclude-filter'
    exclude_filter_el.add_text(REXML::CData.new(exclude_filter))
  end
  unless new_resource.file.nil?
    dcfile = new_resource.file || 'foo'
    if new_resource.source == 'cookbook_file'
      cookbook_file "#{dcfile}_#{new_resource.name}" do
        source dcfile
        path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
        owner 'root'
        group 'root'
        mode 00644
        not_if { new_resource.file.nil? }
      end
    else
      remote_file "#{dcfile}_#{new_resource.name}" do
        source new_resource.source
        path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
        owner 'root'
        group 'root'
        mode 00644
      end
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
end

def restart_collectd
  file "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml" do
    action :touch
  end
end

def delete_snmp_collection_group
  group_name = new_resource.group_name || new_resource.name
  Chef::Log.debug "Deleting snmp collection group : '#{group_name}'"

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  # only remove the reference to the group from the collection - the file stays put in case it is used by another collection
  # or a group in the file is used by another systemDef, etc
  del_el = doc.elements.delete("/datacollection-config/snmp-collection[@name='#{new_resource.collection_name}']/include-collection[@dataCollectionGroup = '#{group_name}']")
  Chef::Log.debug("Deleted element: #{del_el}")

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
end
