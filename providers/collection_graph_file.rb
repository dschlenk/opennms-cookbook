# frozen_string_literal: true
include Graph

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - maybe updating."
    updated = create_collection_graph_file
    converge_by("Update #{@new_resource}") if updated
  else
    Chef::Log.info "#{@new_resource} doesn't exist - creating."
    converge_by("Create #{@new_resource}") do
      create_collection_graph_file
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
  @current_resource = Chef::Resource.resource_for_node(:opennms_collection_graph_file, node).new(@new_resource.name)

  if graph_file_exists?(@current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def create_collection_graph_file
  f = if new_resource.source == 'cookbook_file'
        cookbook_file new_resource.file do
          action :create
          path "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
          owner 'root'
          group 'root'
          mode 00644
        end
      else
        remote_file new_resource.file do
          action :create
          path "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
          source new_resource.source
          owner 'root'
          group 'root'
          mode 00644
        end
      end
  touch_main_file if f.updated_by_last_action?
  f.updated_by_last_action?
end

def delete_collection_graph_file
  if new_resource.source == 'cookbook_file'
    cookbook_file "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}" do
      action :delete
      owner 'root'
      group 'root'
      mode 00644
    end
  else
    remote_file new_resource.file do
      action :delete
      path "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
      source new_resource.source
      owner 'root'
      group 'root'
      mode 00644
    end
  end
  touch_main_file
end

def touch_main_file
  file "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties" do
    action :touch
  end
end
