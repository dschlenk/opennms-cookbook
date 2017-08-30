# frozen_string_literal: true
include Events
def whyrun_supported?
  true
end

use_inline_resources

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
  @current_resource = Chef::Resource::OpennmsEventconf.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if eventconf_exists?(@current_resource.name)
end

private

def eventconf_exists?(name)
  Chef::Log.debug "Checking to see if this eventconf file exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", 'r')
  doc = REXML::Document.new file
  in_eventconf = !doc.elements["/events/event-file[text() = 'events/#{name}' and not(text()[2])]"].nil?
  exists = ::File.exist?("#{node['opennms']['conf']['home']}/etc/events/#{name}")
  in_eventconf && exists
end

def create_eventconf
  Chef::Log.debug "Placing new eventconf file: '#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}'"
  cookbook_file new_resource.name do
    path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
    owner 'root'
    group 'root'
    mode 00644
  end
  add_file_to_eventconf(new_resource.name, new_resource.position, node)
end

def update_eventconf
  f = cookbook_file new_resource.name do
    path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
    owner 'root'
    group 'root'
    mode 00644
  end
  f.updated_by_last_action?
end
