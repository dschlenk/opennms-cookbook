# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_import
    end
  end
end

action :sync do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - syncing."
    converge_by("Sync #{@new_resource}") do
      sync_import_action
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImport.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)

  if foreign_source_exists?(@current_resource.foreign_source_name, node)
    @current_resource.foreign_source_exists = true
  end
  # imports don't actually have their own name.
  if import_exists?(@current_resource.foreign_source_name, node)
    @current_resource.exists = true
  end
end

private

def create_import
  add_import(new_resource.foreign_source_name, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, true, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end

def sync_import_action
  sync_import(new_resource.foreign_source_name, true, node)
  wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
end
