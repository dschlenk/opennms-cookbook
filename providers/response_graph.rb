# frozen_string_literal: true
include Graph
include ResourceType

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_response_graph
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsResponseGraph.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if graph_exists?(@current_resource.name, 'response', node)
    @current_resource.exists = true
  end
end

private

def create_response_graph
  Chef::Log.debug "Creating collection graph #{new_resource.name}."
  add_response_graph(new_resource, node)
end
