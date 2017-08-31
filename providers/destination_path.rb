# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_destination_path
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDestinationPath.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if destination_path_exists?(@current_resource.name)
    @current_resource.exists = true
  end
end

private

def destination_path_exists?(name)
  Chef::Log.debug "Checking to see if this destination path exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/destinationPaths.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/destinationPaths/path[@name='#{name}']"].nil?
end

def create_destination_path
  Chef::Log.debug "Adding destination path: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/destinationPaths.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  paths_el = doc.root.elements['/destinationPaths']
  path_el = paths_el.add_element 'path', 'name' => new_resource.name
  if !new_resource.initial_delay.nil? && !new_resource.initial_delay == '0s'
    path_el.attributes['initial-delay'] = new_resource.initial_delay
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/destinationPaths.xml")
end
