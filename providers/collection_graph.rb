# frozen_string_literal: true
include Graph
include ResourceType

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  unless @current_resource.file_exists
    Chef::Log.info "#{@new_resource} file doesn't exist - creating it."
    new_graph_file(@current_resource.file, node)
  end
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_collection_graph
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsCollectionGraph.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.type(@new_resource.type)
  @current_resource.file(@new_resource.file)

  if !@current_resource.file.nil? && graph_file_exists?(@current_resource.file, node)
    @current_resource.file_exists = true
  elsif @current_resource.file.nil? # because means add it to main graph file like a bad person
    @current_resource.file_exists = true
  end
  if graph_exists?(@current_resource.name, 'collection', node)
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
  touch_main_file
end

def touch_main_file
  file "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties" do
    action :touch
  end
end
