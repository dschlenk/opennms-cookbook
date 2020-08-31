# frozen_string_literal: true
include WsmanCollection

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else converge_by("Create #{@new_resource}") do
    create_wsman_collection
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_collection, node).new(@new_resource.name)
  @current_resource.collection(@new_resource.collection)
  @current_resource.rrd_step(@new_resource.rrd_step)
  @current_resource.rras(@new_resource.rras)
  @current_resource.include_system_definitions(@new_resource.include_system_definitions)
  @current_resource.include_system_definition(@new_resource.include_system_definition)
  @current_resource.exists = true if wsman_service_exists?(@current_resource.collection, node)
end

private



def create_wsman_collection
  created_wsman_collection(@current_resource, node)
end
