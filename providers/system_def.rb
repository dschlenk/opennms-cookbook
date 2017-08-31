# frozen_string_literal: true
include SystemDef

def whyrun_supported?
  true
end

use_inline_resources

action :add do
  Chef::Application.fatal!("Missing one of these data-collection groups: #{@current_resource.groups}.") unless @current_resource.groups_exist
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already in systemDef - nothing to do."
  else
    converge_by("Add #{@new_resource}") do
      add_groups_to_system_def
    end
  end
end

action :remove do
  Chef::Application.fatal!("Missing one of these data-collection groups: #{@current_resource.groups}.") unless @current_resource.groups_exist
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} not present - nothing to do."
  else
    converge_by("Remove #{@new_resource}") do
      remove_groups_from_system_def
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSystemDef.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.groups(@new_resource.groups)

  ge = true
  @current_resource.groups.each do |group|
    next if group_exists?(node['opennms']['conf']['home'], group)
    Chef::Log.error "Missing data-collection group #{group}"
    ge = false
    break
  end
  @current_resource.groups_exist = true if ge
  system_def_file = find_system_def(node['opennms']['conf']['home'], @current_resource.name)
  unless system_def_file.nil?
    @current_resource.system_def_exists = true
    if groups_in_system_def?(node['opennms']['conf']['home'], @current_resource.name, system_def_file, @current_resource.groups)
      @current_resource.exists = true
    end
  end
end

private

def add_groups_to_system_def
  add_groups(node['opennms']['conf']['home'], new_resource.groups, new_resource.name)
end

def remove_groups_from_system_def
  remove_groups(node['opennms']['conf']['home'], new_resource.groups, new_resource.name)
end
