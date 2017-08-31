# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create_if_missing do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_service_detector
    end
  end
end

action :create do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and has not changed - nothing to do."
  elsif @current_resource.exists && @current_resource.changed
    converge_by("Update #{@new_resource}") do
      update_service_detector(new_resource, node)
    end
  else
    converge_by("Create #{@new_resource}") do
      create_service_detector
    end
  end
end

action :delete do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} exists - deleting."
    converge_by("Delete #{@new_resource}") do
      delete_service_detector
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsServiceDetector.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.service_name(@new_resource.service_name || @new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.class_name(@new_resource.class_name)
  @current_resource.port(@new_resource.port)
  @current_resource.retry_count(@new_resource.retry_count)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.params(@new_resource.params)

  if foreign_source_exists?(@current_resource.foreign_source_name, node)
    @current_resource.foreign_source_exists = true
  end
  if service_detector_exists?(@current_resource.service_name, @current_resource.foreign_source_name, node)
    @current_resource.exists = true
    if service_detector_changed?(@current_resource, node)
      @current_resource.changed = true
    end
  end
end

private

def create_service_detector
  add_service_detector(new_resource, node)
end

def delete_service_detector
  remove_service_detector(new_resource, node)
end
