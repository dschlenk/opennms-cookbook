# frozen_string_literal: true

include Wsman
include WsmanSystemDefinition

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :add do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already in system-definition - nothing to do."
  else
    Chef::Log.info "#{@new_resource} doesn't exist - create new system definition."
    add_system_definition
  end
end

action :remove do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else converge_by("Remove #{@new_resource}") do
    remove_system_definition
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_system_definition, node).new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.groups(@new_resource.groups)
  @current_resource.position(@new_resource.position)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"

  unless ::File.exist?(@current_resource.file_path)
    create_file(node, new_resource.file_name)
  end

  @current_resource.exists = false

  new_resource.groups.each do |group|
    group_element = included_group_xpath(group)
    group_file = find_file_path(node, group_element, group)
    next if group_file.nil?
    Chef::Log.debug "Found group in file: #{group_file}"
    @current_resource.exists = true
    break
  end
end

private

def add_system_definition
  sys_def_element = system_definition_xpath(new_resource.name)
  system_def_file = find_file_path(node, sys_def_element, new_resource.name)
  if system_def_file.nil?
    Chef::Log.debug "Add system definition to  #{@current_resource.file_path}"
    create_system_definition(@current_resource.file_path, new_resource)
  else
    Chef::Log.debug "Add system definition to  #{system_def_file}"
    add_wsman_system_definition(node, system_def_file, new_resource)
  end
end

def remove_system_definition
  sys_def_element = system_definition_xpath(new_resource.name)
  system_def_file = find_file_path(node, sys_def_element, new_resource.name)
  if !system_def_file.nil?
    remove_wsman_system_definition(system_def_file, new_resource)
  else
    Chef::Log.debug 'No system definition. Nothing to delete'
  end
end
