include Provision
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") if !@current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_service_detector
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsServiceDetector.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)

  if foreign_source_exists?(@current_resource.foreign_source_name, node)
     @current_resource.foreign_source_exists = true
  end
  if service_detector_exists?(@current_resource.name, @current_resource.foreign_source_name, node)
     @current_resource.exists = true
  end
end

private

def create_service_detector
  add_service_detector(new_resource.name,new_resource.class_name, 
    new_resource.port, new_resource.retry_count, new_resource.timeout, 
    new_resource.params, new_resource.foreign_source_name, node)
end
