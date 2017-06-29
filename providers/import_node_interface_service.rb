# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") unless @current_resource.import_exists
  Chef::Application.fatal!("Missing node with foreign ID #{@current_resource.foreign_id}.") unless @current_resource.node_exists
  Chef::Application.fatal!("Missing interface #{@current_resource.ip_addr}.") unless @current_resource.interface_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_import_node_interface_service
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImportNodeInterfaceService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.foreign_id(@new_resource.foreign_id)
  @current_resource.ip_addr(@new_resource.ip_addr)

  if import_exists?(@current_resource.foreign_source_name, node)
    @current_resource.import_exists = true
  end
  if import_node_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, node)
    @current_resource.node_exists = true
  end
  if import_node_interface_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, @current_resource.ip_addr, node)
    @current_resource.interface_exists = true
  end
  if import_node_interface_service_exists?(@current_resource.name, @current_resource.foreign_source_name, @current_resource.foreign_id, @current_resource.ip_addr, node)
    @current_resource.exists = true
  end
end

private

def create_import_node_interface_service
  Chef::Log.debug 'Adding service...'
  add_import_node_interface_service(new_resource.name, new_resource.foreign_source_name,
    new_resource.foreign_id, new_resource.ip_addr, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name, false, node)
    wait_for_sync(new_resource.foreign_source_name, node,
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end
