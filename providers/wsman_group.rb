# frozen_string_literal: true
#
include ResourceType
include Wsman

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - create new wsman group."
    create_wsman_group
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else converge_by("Delete #{@new_resource}") do
    delete_wsman_group
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.sysdef_name)
  @current_resource.sysdef_name(@new_resource.sysdef_name)
  @current_resource.group_name(@new_resource.group_name)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)
  @current_resource.attribs(@new_resource.attribs)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"

  if !file_exists?(@new_resource.file_name, node)
    create_file(node, @new_resource.file_name)
  end

  @current_resource.exists = false
  if wsman_group_exists?(@new_resource.group_name, node)
    Chef::Log.debug("group #{@current_resource.group_name} is in file already")
    @current_resource.exists = true
  end
  @current_resource.sys_def_exists = false
  system_definition_name = @current_resource.sysdef_name

  if !system_definition_name.nil?
    if system_definition_exist?(@current_resource.sysdef_name, node)
      @current_resource.sys_def_exists = true
    end
  end
end

private

def create_wsman_group
  if !wsman_group_exists?(@current_resource.group_name, node)
    Chef::Log.debug "Creating wsman group : #{new_resource.group_name}"
    f = ::File.new("#{@current_resource.file_path}")
    Chef::Log.debug "file name : '#{new_resource.file_name}'"
    contents = f.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote

    if new_resource.position == 'top'
      #Check for first group in the file
      if !doc.elements['/wsman-datacollection-config/group[1]'].nil?
        group_el = REXML::Element.new 'group'
        first_group = doc.elements['/wsman-datacollection-config/group[1]']
        doc.root.insert_before(first_group, group_el)
      elsif !doc.root.elements['/wsman-datacollection-config/system-definition[1]'].nil?
        first_sys_def = doc.elements['/wsman-datacollection-config/system-definition[1]']
        group_el = REXML::Element.new 'group'
        doc.root.insert_before(first_sys_def, group_el)
      elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
        last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
        group_el = REXML::Element.new 'group'
        doc.root.insert_after(last_collection, group_el)
      else group_el = doc.root.add_element 'group'
      end
    else #add to bottom
      if !doc.elements['/wsman-datacollection-config/group[last()]'].nil?
        group_el = REXML::Element.new 'group'
        last_group = doc.elements['/wsman-datacollection-config/group[last()]']
        doc.root.insert_after(last_group, group_el)
      elsif !doc.root.elements['/wsman-datacollection-config/system-definition[1]'].nil?
        first_sys_def = doc.elements['/wsman-datacollection-config/system-definition[1]']
        group_el = REXML::Element.new 'group'
        doc.root.insert_before(first_sys_def, group_el)
      elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
        last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
        group_el = REXML::Element.new 'group'
        doc.root.insert_after(last_collection, group_el)
      else group_el = doc.root.add_element 'group'
      end
    end

    if !group_el.nil?
      group_el.attributes['name'] = new_resource.group_name
      group_el.attributes['resource-type'] = new_resource.resource_type
      group_el.attributes['resource-uri'] = new_resource.resource_uri

      unless new_resource.dialect.nil?
        group_el.attributes['dialect'] = new_resource.dialect
      end

      unless new_resource.filter.nil?
        group_el.attributes['filter'] = new_resource.filter
      end

      unless new_resource.attribs.nil?
        begin
          new_resource.attribs.each do |name, details|
            attrib_el = group_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'type' => details['type']
            attrib_el.add_attribute('index-of', details['index-of']) if details['index-of']
            attrib_el.add_attribute('filter', details['filter']) if details['filter']
          end
        end
      end
    end
    Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")

    if !include_group_exists?(new_resource.group_name, node)
      insert_included_def
    end
  end
end

def delete_wsman_group()
  group = find_wsman_group(node, @current_resource.group_name)
  if !group.nil?
    Chef::Log.debug "Delete Group : '#{@current_resource.group_name}'"
    delete_group(group)
  end

  if include_group_exists?(@current_resource.group_name, node)
    Chef::Log.debug "Delete Include Group from System Definition : '#{@current_resource.group_name}'"
    delete_included_def
  end
end

#This method is not yet finished developed and not testing yet
def update_wsman_group() #The change may have less or more attributes. it clean to delete the match group name then add new group with same name and new data
  Chef::Log.debug "file name : '#{@current_resource.file_path}'"
  file = ::File.new(@current_resource.file_path, 'r')
  doc = REXML::Document.new file
  file.close

  if group_in_file?(@current_resource.file_path, @current_resource.group_name)
    Chef::Log.debug "group_in_file?: 'true'"
    del_el = doc.elements.delete("/wsman-datacollection-config/group[@name='#{new_resource.group_name}']")
    Chef::Log.debug("Deleted element: #{del_el}")
  end

  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")

  create_wsman_group
end

def delete_group(group)
  Chef::Log.debug "delete grooup in file : '#{group}'"
  file = ::File.new("#{group}", 'r')
  doc = REXML::Document.new file
  file.close

  del_el = doc.elements.delete("/wsman-datacollection-config/group[@name='#{new_resource.group_name}']")
  Chef::Log.debug("Deleted element: #{del_el}")

  Opennms::Helpers.write_xml_file(doc, "#{group}")
end

def delete_included_def()
  included_group = find_include_group(node, @current_resource.group_name)
  Chef::Log.debug "included_group_in_file?: '#{included_group}'"

  file = ::File.new("#{included_group}", 'r')
  doc = REXML::Document.new file
  file.close

  del_el = doc.elements.delete("/wsman-datacollection-config/system-definition/include-group[text() = '#{@current_resource.group_name}']")
  Chef::Log.debug("Deleted include-group successfully: #{del_el}")

  Opennms::Helpers.write_xml_file(doc, "#{included_group}")
end


def insert_included_def()
  Chef::Log.debug "No system definition included. Add system definition for : '#{new_resource.sysdef_name}'"
  if @current_resource.sys_def_exists
    sys_def_file = find_system_definition(node, "#{@current_resource.sysdef_name}")
    puts sys_def_file
    Chef::Log.debug "Current System Definition '#{@current_resource.sysdef_name}' exist in: '#{sys_def_file}'"
    insert_system_definition_include_group(sys_def_file)
  end
end

def insert_system_definition_include_group(file_path)
  file = ::File.new("#{file_path}", 'r')
  doc = REXML::Document.new file
  file.close

  system_definition_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.sysdef_name}']"]

  if !system_definition_el.nil?
    Chef::Log.debug "Insert Include Group '#{new_resource.group_name}' to existing system definition: '#{new_resource.sysdef_name}'"
    incl_def_el = system_definition_el.add_element 'include-group'
    incl_def_el.add_text("#{new_resource.group_name}")
  end
  Opennms::Helpers.write_xml_file(doc, "#{file_path}")
end



def system_def_in_file?(file)
  Chef::Log.debug "Group in File : '#{file}'"
  file = ::File.new("#{file}", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements[system_definition_xpath].nil?
end

def group_in_file?(file, group)
  Chef::Log.debug "Group in File : '#{file}'"
  file = ::File.new("#{file}", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements[group_xpath(group)].nil?
end

def include_group_in_file?(file, group)
  Chef::Log.debug "include-group in File : '#{file}'"
  file = ::File.new("#{file}", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements[include_group_xpath(group)].nil?
end

def include_group_xpath(group)
  include_group_xpath = "/wsman-datacollection-config/system-definition/include-group[text() = '#{group}']"
  Chef::Log.debug "group xpath is: #{include_group_xpath}"
  include_group_xpath
end

def group_xpath(group)
  group_xpath = "/wsman-datacollection-config/group[@name='#{group}']"
  Chef::Log.debug "group xpath is: #{group_xpath}"
  group_xpath
end

def system_definition_xpath() #get the first system difiniton on the file if exist
  system_definition_xpath = "/wsman-datacollection-config/system-definition[@name='#{new_resource.sysdef_name}']"
  Chef::Log.debug "system_definition_xpath  is: #{system_definition_xpath}"
  system_definition_xpath
end


#Code below are not tested yet
def group_equal?
  Chef::Log.debug "file name : '#{@current_resource.file_path}'"
  file = ::File.new("#{@current_resource.file_path}", 'r')
  doc = REXML::Document.new file
  file.close

  if group_in_file?("#{@current_resource.file_path}", new_resource.group_name)
    Chef::Log.debug "group_in_file?: #{@current_resource.file_path}"
    group_el = doc.elements["/wsman-datacollection-config/group[@name='#{new_resource.group_name}']"]
    return true if group_el.nil? && (new_resource.nil? || new_resource.empty?)

    if resource_type_equal?(group_el) \
          && resource_uri_equal?(group_el) \
          && dialect_equal?(group_el) \
          && filters_equal?(group_el) \
          && attribute_equal?(doc)
      true
    else false
    end
  end
end

def resource_type_equal?(doc)
  return true if doc.attributes['resource-type'].nil? && @current_resource.resource_type.nil?

  Chef::Log.debug "resource_type_equal?: #{@current_resource.resource_type}"
  doc.attributes['resource-type'].to_s == @current_resource.resource_type.to_s
end

def resource_uri_equal?(doc)
  return true if doc.attributes['resource-uri'].nil? && @current_resource.resource_uri.nil?

  Chef::Log.debug "resource-uril?: #{@current_resource.resource_uri}"
  doc.attributes['resource-uri'].to_s == @current_resource.resource_uri.to_s
end

def dialect_equal?(doc)
  return true if doc.attributes['dialect'].nil? && @current_resource.dialect.nil?

  unless doc.attributes['dialect'].nil? && @current_resource.dialect.nil?
    Chef::Log.debug "dialect_equal??: #{@current_resource.dialect}"
    doc.attributes['dialect'].to_s == @current_resource.dialect.to_s
  end
end

def filters_equal? (doc)
  return true if doc.attributes['filter'].nil? && @current_resource.filter.nil?

  unless doc.attributes['filter'].nil? && @current_resource.filter.nil?
    Chef::Log.debug "filter_equal?: #{@current_resource.filter}"
    doc.attributes['filter'].to_s == @current_resource.filter.to_s
  end
end

def attribute_equal?(doc)
  Chef::Log.debug "attribute_equal??: #{@current_resource.attribs}"
  attribute_el = doc.elements["/wsman-datacollection-config/group[@name='#{@current_resource.group_name}/attrib']"]
  return true if attribute_el.nil? && (@current_resource.attribs.nil? || @current_resource.attribs.empty?)

  unless @current_resource.attribs.nil?
    begin
      @current_resource.attribs.each do |name, details|
        group_el = doc.elements["/wsman-datacollection-config/group[@name='#{@current_resource.group_name}']/attrib"]
        group_el.each do |att|
          return true if att.attribute['name'].nil? && name.nil?
          if att.attribute['name'] == name
            attrib_el = doc.elements["/wsman-datacollection-config/group[@name='#{@current_resource.group_name}/attrib/[@name='#{name}']"]
            return true if attrib_el.nil? && (name.nil? || name.to_s == '')
            if alias_equal?(attrib_el, details['alias'])  \
             && type_equal?(attrib_el, details['type']) \
             && filter_equal?(attrib_el, details['filter']) \
             && index_of_equal?(attrib_el, details['index-of'])
            end
          end
        end
      end
    end
  end
end

def alias_equal?(doc, current_resource)
  return true if doc.attributes['alias'].nil? && current_resource.nil?
  Chef::Log.debug "alias_equal?: #{current_resource.to_s}"
  doc.attributes['alias'].to_s == current_resource.to_s
end

def type_equal?(doc, current_resource)
  return true if doc.attributes['type'].nil? && current_resource.nil?
  Chef::Log.debug "type?: #{current_resource.to_s}"
  doc.attributes['type'].to_s == current_resource.to_s
end

def filter_equal?(doc, current_resource)
  return true if doc.attributes['filter'].nil? && current_resource.nil?
  Chef::Log.debug "filter?: #{current_resource.to_s}"
  unless doc.attributes['filter'].nil? && current_resource.nil?
    doc.attributes['filter'].to_s == current_resource.to_s
  end
end

def index_of_equal?(doc, current_resource)
  return true if doc.attributes['index-of'].nil? && current_resource.nil?
  Chef::Log.debug "index-of?: #{current_resource.to_s}"
  unless doc.attributes['index-of'].nil? && current_resource.nil?
    doc.attributes['index-of'].to_s == current_resource.to_s
  end
end


