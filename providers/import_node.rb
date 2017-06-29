# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") unless @current_resource.import_exists
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and has not changed - nothing to do."
  elsif @current_resource.exists && @current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and has changed - updating."
    converge_by("Create #{@new_resource}") do
      update_node
    end
  else
    converge_by("Create #{@new_resource}") do
      create_import_node
    end
  end
end

action :create_if_missing do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") unless @current_resource.import_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_import_node
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_node
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImportNode.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.node_label(@new_resource.node_label)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.foreign_id(@new_resource.foreign_id)
  @current_resource.parent_foreign_source(@new_resource.parent_foreign_source)
  @current_resource.parent_foreign_id(@new_resource.parent_foreign_id)
  @current_resource.parent_node_label(@new_resource.parent_node_label)
  @current_resource.city(@new_resource.city)
  @current_resource.building(@new_resource.building)
  @current_resource.categories(@new_resource.categories)
  @current_resource.assets(@new_resource.assets)

  if import_exists?(@current_resource.foreign_source_name, node)
    @current_resource.import_exists = true
  end
  if import_node_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, node)
    @current_resource.exists = true
    if import_node_changed?(@current_resource, node)
      @current_resource.changed = true
    end
  end
end

private

def update_node
  update_imported_node(new_resource, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, true, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end

def create_import_node
  add_import_node(new_resource, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, true, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end

def delete_node
  delete_imported_node(new_resource.foreign_id, new_resource.foreign_source_name, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, true, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end
