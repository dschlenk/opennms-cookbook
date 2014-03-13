include Provision
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.name}.") if !@current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_import
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsImport.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if foreign_source_exists?(@current_resource.name, node)
     @current_resource.foreign_source_exists = true
  end
  if import_exists?(@current_resource.name, node)
     @current_resource.exists = true
  end
end

private

def create_import
  add_import(new_resource.name, node)
  sync_import(new_resource.name,true, node) if !new_resource.sync_import.nil? && new_resource.sync_import
end
