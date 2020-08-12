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

  if @current_resource.file == "wsman-datacollection-config.xml" || ""
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
  contents = f.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  f.close

  root_el = doc.elements["/wsman-datacollection-config/"]
  group_el = root_el.elements[group_xpath(new_resource)]

  # see if there's an existing group element
  last_group_el = root_el.elements['group[last()]']
  group = doc.root.elements["/wsman-datacollection-config/group[@name = '#{new_resource.group_name}']"]
  if new_resource.position == 'bottom'
    if !last_group_el.nil?
      group.insert_after(last_group_el, group_el)
    else last_group_el = root_el.elements['system-definition[first()]']
    if !last_group_el.nil?
      group.insert_before(last_group_el, group_el)
    else group.add_element group_el
    end
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")
end

def group_xpath(group)
  group_el = REXML::Element.new('group')
  group_el.add_attribute['name'] = group.group_name

  unless group.resource_uri.nil?
    group_el.add_attribute['resource-uri'] = group.resource_uri
  end

  unless group.dialect.nil?
    group_el.add_attribute['dialect'] = group.dialect
  end

  unless group.filter.nil?
    group_el.add_attribute['filter'] = group.filter
  end

  unless group.resource_type.nil?
    group_el.add_attribute['resource-type'] = group.resource_type
  end

  unless group.attribs.nil?
    group.attribs.each do |name, details|
      attrib_el = REXML::Element.new('attrib')
      attrib_el.attributes['name'] = name
      attrib_el.attributes['alias'] = details['alias']
      attrib_el.attributes['type'] = details['type']
      unless details['index-of'].nil?
        attrib_el.attributes['index-of'] = details['index-of']
      end
      group_el.elements[attrib_el]
    end
  end
end