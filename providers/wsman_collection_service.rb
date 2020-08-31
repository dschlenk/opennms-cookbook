# frozen_string_literal: true
include WsmanCollectionService

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - checking if changed."
    if @current_resource.changed
      Chef::Log.info "#{@new_resource} has changed - updating."
      converge_by("Update #{@new_resource}") do
        update_wsman_collection_service
      end
    end
  else
    converge_by("Create #{@new_resource}") do
      create_wsman_collection_service
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_collection_service, node).new(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource.interval(@new_resource.interval)
  @current_resource.user_defined(@new_resource.user_defined)
  @current_resource.status(@new_resource.status)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.retry_count(@new_resource.retry_count)
  @current_resource.port(@new_resource.port) unless @new_resource.port.nil?
  @current_resource.collection(@new_resource.collection)
  @current_resource.thresholding_enabled(@new_resource.thresholding_enabled)

  if service_exists?(@current_resource.package_name,
                     @current_resource.collection,
                     @current_resource.service_name)
    @current_resource.exists = true
    @current_resource.changed = true if  service_changed?(@current_resource, node)
  end
end

private

def update_wsman_collection_service
  updated_wsman_collection_service(@current_resource, node)
end

def create_wsman_collection_service
  created_wsman_collection_service(@current_resource, node)
end
