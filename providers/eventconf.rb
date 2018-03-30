# frozen_string_literal: true
include Events
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
    updated = update_eventconf
    if updated
      converge_by("Update #{@new_resource}") do
      end
    end
  else
    converge_by("Create #{@new_resource}") do
      create_eventconf
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_eventconf, node).new(@new_resource.name)
  @current_resource.source(@new_resource.source)

  @current_resource.exists = true if eventconf_exists?(@current_resource)
end

private

def eventconf_exists?(current_resource)
  Chef::Log.debug "Checking to see if this eventconf file exists: '#{current_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", 'r')
  doc = REXML::Document.new file
  in_eventconf = !doc.elements["/events/event-file[text() = 'events/#{current_resource.name}' and not(text()[2])]"].nil?
  exists = ::File.exist?("#{node['opennms']['conf']['home']}/etc/events/#{current_resource.name}")
  in_eventconf && exists
end

def create_eventconf
  Chef::Log.debug "Placing new eventconf file: '#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}'"
  if new_resource.source == 'cookbook_file'
    cookbook_file new_resource.name do
      path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
      owner 'root'
      group 'root'
      mode 00644
    end
  else
    remote_file new_resource.name do
      path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
      source new_resource.source
      owner 'root'
      group 'root'
      mode 00644
    end
  end
  add_file_to_eventconf(new_resource.name, new_resource.position, node)
end

def update_eventconf
  f = if new_resource.source == 'cookbook_file'
        cookbook_file new_resource.name do
          path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
          owner 'root'
          group 'root'
          mode 00644
        end
      else
        remote_file new_resource.name do
          path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
          source new_resource.source
          owner 'root'
          group 'root'
          mode 00644
        end
      end
  f.updated_by_last_action?
end
