include Provision
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing requisition #{@current_resource.foreign_source_name}.") if !@current_resource.import_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_import_node
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImportNode.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)
  @current_resource.foreign_id(@new_resource.foreign_id)

  if import_exists?(@current_resource.foreign_source_name, node)
     @current_resource.import_exists = true
  end
  if import_node_exists?(@current_resource.foreign_source_name, @current_resource.foreign_id, node)
     @current_resource.exists = true
  end
end

private

def create_import_node
  add_import_node(new_resource.name, new_resource.foreign_id, new_resource.parent_foreign_source, new_resource.parent_foreign_id, new_resource.parent_node_label, new_resource.city, new_resource.building, new_resource.categories, new_resource.assets, new_resource.foreign_source_name, node)
  if !new_resource.sync_import.nil? && new_resource.sync_import
    sync_import(new_resource.foreign_source_name,true, node) 
    wait_for_sync(new_resource.foreign_source_name, node, 
                  new_resource.sync_wait_periods, new_resource.sync_wait_secs)
  end
end
