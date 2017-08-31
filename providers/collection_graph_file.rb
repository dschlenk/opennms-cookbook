# frozen_string_literal: true
include Graph

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - maybe updating."
    updated = update_collection_graph_file
    if updated
      converge_by("Update #{@new_resource}") do
        touch_main_file
      end
    end
  else
    Chef::Log.info "#{@new_resource} doesn't exist - creating."
    converge_by("Create #{@new_resource}") do
      update_collection_graph_file
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create if missing #{@new_resource}") do
      create_collection_graph_file
    end
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else
    converge_by("Delete #{@new_resource}") do
      delete_collection_graph_file
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsCollectionGraphFile.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if graph_file_exists?(@current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def update_collection_graph_file
  f = cookbook_file new_resource.file do
    action :create
    path "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
    owner 'root'
    group 'root'
    mode 00644
  end
  f.updated_by_last_action?
end

def create_collection_graph_file
  cookbook_file new_resource.file do
    action :create_if_missing
    path "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
    owner 'root'
    group 'root'
    mode 00644
  end
  touch_main_file
end

def delete_collection_graph_file
  cookbook_file "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}" do
    action :delete
    owner 'root'
    group 'root'
    mode 00644
  end
  touch_main_file
end

def touch_main_file
  file "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties" do
    action :touch
  end
end
