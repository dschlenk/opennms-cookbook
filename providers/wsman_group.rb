# frozen_string_literal: true
include WsmanGroups

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else converge_by("Create #{@new_resource}") do
    create_wsman_group
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.group_name)
  @current_resource.file(@new_resource.file)
  @current_resource.group_name(@new_resource.group_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)

  if @current_resource.file == "wsman-datacollection-config.xml"
    @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
  else @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{@current_resource.file}"
  @current_resource.file_exists = File.exist?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{@current_resource.file}")
  if !@current_resource.file_exists
    create_wsman_group_file
  end
  end
  if group_file?(@current_resource.file_path)
    @current_resource.is_group_file = true
    if group_in_file?("#{@current_resource.file_path}", @current_resource.group_name)
      Chef::Log.debug("group #{@current_resource.group_name} is in file already")
      @current_resource.exists = true
      if group_changed?(@current_resource.file_path, @current_resource)
        Chef::Log.debug("group #{@current_resource.group_name} has changed.")
        @current_resource.changed = true
      end
    end
  end

  if group_exists?(@current_resource.group_name)
    @current_resource.group_exists = true
  end
end

private

def group_file?(file_path)
  fn = file_path
  groupfile = false
  if ::File.exist?(fn)
    file = ::File.new(fn, 'r')
    doc = REXML::Document.new file
    file.close
    groupfile = !doc.elements["/wsman-datacollection-config/group"].nil?
  end
  groupfile
end

def create_wsman_group_file
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new
  group_el = doc.add_element 'wsman-datacollection-config'
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{new_resource.file}")
end

def group_exists?(group_name)
  Chef::Log.debug "Checking to see if this ws-man group exists: '#{group_name}'"
  file = ::File.new("#{@current_resource.file_path}", 'r')
  doc = REXML::Document.new file
  !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?
end

def create_wsman_group
  f = ::File.new("#{@current_resource.file_path}")
  Chef::Log.debug "Creating wsman group : '#{new_resource.file}' #{@current_resource.file_path}"
  contents = f.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  root_el = doc.elements["/wsman-datacollection-config"]
  grooup_el = root_el.add_element 'group', 'name' => new_resource.name,'resource-uri' => new_resource.resource_uri, 'dialect' => new_resource.dialect,  'filter' => new_resource.filter, 'resource-type' => new_resource.resource_type

  new_resource.attribs.each do |name, details|
    attrib_el = grooup_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'filter' => details['filter'], 'type' => details['type'], 'type' => details['type'], 'index-of' => details['index-of']
    attrib_el.add_attribute('maxval', details['maxval']) if details['maxval']
    attrib_el.add_attribute('minval', details['minval']) if details['minval']
  end

  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")
end
