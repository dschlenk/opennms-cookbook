include Graph
include ResourceType

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_collection_graph
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsCollectionGraph.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.type(@new_resource.type)

  if graph_exists?(@current_resource.name, node)
    @current_resource.exists = true
  end

  if rt_exists?(node['opennms']['conf']['home'], @current_resource.type) && rt_included?(node['opennms']['conf']['home'], @current_resource.type)
    @current_resource.type_exists = true
  end
end

private

def create_collection_graph
  Chef::Log.debug "Creating collection graph #{new_resource.name} in #{new_resource.file}."
  add_collection_graph(new_resource, node)
end
