# frozen_string_literal: true
#
include ResourceType
include Wsman
include WsmanGroup

action :create do
  unless @current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - create new wsman group."
    create_wsman_group
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else
    converge_by("Delete #{@new_resource}") do
      delete_wsman_group
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.name)
  @current_resource.group_name(@new_resource.group_name || @new_resource.name)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)
  @current_resource.attribs(@new_resource.attribs)

  @current_resource.exists = false
  return unless ::File.exist?("#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}")

  group_element = group_xpath(new_resource.group_name)
  group_file = find_file_path(node, group_element, new_resource.group_name)
  unless group_file.nil?
    Chef::Log.debug("group #{new_resource.group_name} is in file already")
    @current_resource.exists = true
  end
end

private

def create_wsman_group
  fp = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"
  create_file(node, new_resource.file_name) unless ::File.exist?(fp)
  group_element = group_xpath(new_resource.group_name || new_resource.name)
  created_wsman_group(new_resource, fp, node) unless exists?(fp, group_element)
end

def delete_wsman_group
  gn = new_resource.group_name || new_resource.name
  group_element = group_xpath(gn)
  group_file = find_file_path(node, group_element, gn)

  unless group_file.nil?
    Chef::Log.debug "Delete Group : '#{gn}'"
    delete_group(group_file, gn)
  end
end
