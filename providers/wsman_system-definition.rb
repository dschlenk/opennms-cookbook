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
  @current_resource.groups(@new_resource.groups)
  @current_resource.position(@new_resource.position)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"


  if !::File.exist?(@current_resource.file_path)
    create_file(node, @new_resource.file_name)
  end

  @current_resource.exists = false
  system_definition_name = @current_resource.name

  if !system_definition_name.nil?
    system_definition_element = system_definition_xpath(@current_resource.name)
    sys_def_file =  findFilePath(node, system_definition_element, @current_resource.name)
    if !sys_def_file.nil?
      if groups_in_system_definition?(@current_resource.name, @current_resource.file_path, @current_resource.groups)
        @current_resource.exists = true
      end
    else
      create_system_definition("#{@current_resource.file_path}", "#{@current_resource.name}")
    end
  end

  ge = true

  @current_resource.groups.each do |group|
    group_element = group_xpath("#{group}")
    group_file = findFilePath(node, group_element, "#{group}")
    if group_file.nil?
      Chef::Log.error "Missing data-collection group #{group}"
      ge = false
      break
    end
    @current_resource.group_exists = true if ge
  end
end


private

def add_system_definition
  add_wsman_system_definition(node, @current_resource)
end

def remove_system_definition
  remove_wsman_system_definition(node, @current_resource)
end