# frozen_string_literal: true
#
include ResourceType
include Wsman
include WsmanGroup

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - create new wsman group."
    create_wsman_group
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else converge_by("Delete #{@new_resource}") do
    delete_wsman_group
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.sysdef_name)
  @current_resource.sysdef_name(@new_resource.sysdef_name)
  @current_resource.group_name(@new_resource.group_name)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)
  @current_resource.attribs(@new_resource.attribs)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"

  if !::File.exist?(@current_resource.file_path)
    create_file(node, @new_resource.file_name)
  end

  @current_resource.exists = false
  group_element = group_xpath(@current_resource.group_name)
  group_file = findFilePath(node, group_element, @current_resource.group_name)
  if !group_file.nil?
    Chef::Log.debug("group #{@current_resource.group_name} is in file already")
    @current_resource.exists = true
  end
  @current_resource.sys_def_exists = false
    sys_def_element = system_definition_xpath(@current_resource.sysdef_name)
    sys_def_file =findFilePath(node, sys_def_element, @current_resource.sysdef_name)
    if !sys_def_file.nil?
      @current_resource.sys_def_exists = true
    end
end


private

def create_wsman_group
  created_wsman_group(@current_resource, node)

  if (@current_resource.sys_def_exists)
    sys_def_element ="/wsman-datacollection-config/system-definition/include-group[text() = '#{@current_resource.group_name}']"
    included_group_file = findFilePath(node, sys_def_element, @current_resource.group_name)
    if !included_group_file.nil?
      insert_included_def(@current_resource.sysdef_name)
    end
  end

end

def delete_wsman_group
  group_element = group_xpath(@current_resource.group_name)
  group_file = findFilePath(node, group_element, "#{@current_resource.group_name}")

  if !group_file.nil?
    Chef::Log.debug "Delete Group : '#{@current_resource.group_name}'"
    delete_group(group_file, "#{@current_resource.group_name}")
  end

  include_element = included_group_xpath(@current_resource.group_name)
  include_group_file = findFilePath(node, include_element, "#{@current_resource.group_name}")
  if @current_resource.sys_def_exists
    if !include_group_file.nil?
      Chef::Log.debug "Delete Include Group from System Definition : '#{@current_resource.group_name}'"
      delete_included_def("#{@current_resource.group_name}")
    end
  end
end