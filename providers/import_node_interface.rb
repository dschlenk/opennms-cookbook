# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") unless @current_resource.import_exists
  Chef::Application.fatal!("Missing node with foreign ID #{@current_resource.foreign_id}.") unless @current_resource.node_exists
  if @current_resource.exists
    if @new_resource.sync_import && @new_resource.sync_existing
      converge_by("Exists, but syncing import #{@new_resource}") do
        sync_import_node_interface
      end
    else
      Chef::Log.info "#{@new_resource} already exists - nothing to do."
    end
  else
    converge_by("Create #{@new_resource}") do
      create_import_node_interface
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImportNodeInterface.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.foreign_id(@new_resource.foreign_id)

  if import_exists?(@current_resource.foreign_source_name, node)
    @current_resource.import_exists = true
  end
  if import_node_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, node)
    @current_resource.node_exists = true
  end
  if import_node_interface_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, @current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def create_import_node_interface
  Chef::Log.debug 'Adding interface...'
  add_import_node_interface(new_resource, node)
  Chef::Log.debug "Added interface. Doing import... syncing? #{new_resource.sync_import}"

  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, true, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
  Chef::Log.debug 'imported!'
end

def sync_import_node_interface
  Chef::Log.debug 'syncing import!'
  sync_import(new_resource.foreign_source_name, true, node)
  wait_for_sync(new_resource.foreign_source_name, node,
                new_resource.sync_wait_periods, new_resource.sync_wait_secs)
end
