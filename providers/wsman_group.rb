# frozen_string_literal: true
#
include ResourceType
include Chef::Mixin::ShellOut

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
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_group, node).new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.group_name(@new_resource.group_name)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)
  @current_resource.attribs(@new_resource.attribs)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"

  if !group_file?(@new_resource.file_name, node)
    create_wsman_group_file
  end

  @current_resource.exists = false
  if group_exists?(@new_resource.group_name)
    Chef::Log.debug("group #{@current_resource.group_name} is in file already")
    @current_resource.exists = true
  end
  @current_resource.sys_def_exists = false
  if system_definition_exist?(@current_resource.name)
    @current_resource.sys_def_exists = true
  end
end

private

def create_wsman_group
  if !group_exists?(@current_resource.group_name)
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

    if !include_group_exists?(new_resource.group_name)
      insert_included_def
    end
  end
end

def delete_wsman_group()
  if group_in_file?(@current_resource.file_path, @current_resource.group_name)
    Chef::Log.debug "Delete Group : '#{@current_resource.group_name}'"
    delete_group
  end

  if include_group_exists?(@current_resource.group_name)
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

def delete_group()
  Chef::Log.debug "file name : '#{@current_resource.file_path}'"
  file = ::File.new(@current_resource.file_path, 'r')
  doc = REXML::Document.new file
  file.close

  del_el = doc.elements.delete("/wsman-datacollection-config/group[@name='#{new_resource.group_name}']")
  Chef::Log.debug("Deleted element: #{del_el}")

  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")
end

def delete_included_def()
  Chef::Log.debug "included_group_in_file?: '#{@current_resource.include_group_file_path}'"

  file = ::File.new(@current_resource.include_group_file_path, 'r')
  doc = REXML::Document.new file
  file.close

  del_el = doc.elements.delete("/wsman-datacollection-config/system-definition/include-group[text() = '#{@current_resource.group_name}']")
  Chef::Log.debug("Deleted include-group successfully: #{del_el}")

  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.include_group_file_path}")
end


def insert_included_def()
  Chef::Log.debug "No system definition included. Add system definition for group: '#{new_resource.name}'"
  if @current_resource.sys_def_exists
    Chef::Log.debug "Current System Definition '#{@current_resource.name}' exist in: '#{@current_resource.system_definition_file_path}'"
    insert_system_definition_include_group("#{@current_resource.system_definition_file_path}")
  end
end

def insert_system_definition_include_group(name)
  file = ::File.new("#{name}", 'r')
  doc = REXML::Document.new file
  file.close

  system_definition_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"]

  if !system_definition_el.nil?
    Chef::Log.debug "Insert Include Group '#{new_resource.group_name}' to existing system definition: '#{new_resource.name}'"
    incl_def_el = system_definition_el.add_element 'include-group'
    incl_def_el.add_text("#{new_resource.group_name}")
  end
  Opennms::Helpers.write_xml_file(doc, "#{name}")
end

def create_wsman_group_file ()
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new
  root_el = doc.add_element 'wsman-datacollection-config'
  root_el.add_text("\n")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}")
end

def group_exists?(group_name)
  Chef::Log.debug "Checking to see if this ws-man group exists: '#{group_name}'"

  #Check to see if group exist in wsman-datacollection-config.xml
  Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  exists = !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?

  if exists
    @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    return exists
  else exists = group_exist_sub_folder?(group_name)
  end
  Chef::Log.debug("dir search for group name #{group_name} complete")
  exists
end

def group_exist_sub_folder?(group_name) # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
  groupfile = shell_out("grep -l #{group_name} #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
  if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
    begin
      exists = group_in_file?(groupfile.stdout.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{groupfile.stdout.chomp}")
        @current_resource.file_path = "#{groupfile.stdout.chomp}"
        return exists
      end
    end
  else # if multiple files match, only return if true since could be a regex false positive.
    groupfile.stdout.lines.each do |file|
      exists = group_in_file?(file.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{file}")
        @current_resource.file_path = "#{file}"
        return exists
      end
    end
  end

  # okay, we'll do it right now, but this is slow.
  Chef::Log.debug("Starting dir search for group name #{group_name}")
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
    next if file !~ /.*\.xml$/
    exists = group_in_file?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
    if exists
      @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}"
    end
    break if exists
  end
end

def system_definition_exist?(sys_def_name)
  #Check to see if group exist in wsman-datacollection-config.xml
  Chef::Log.debug "Checking to see if system definition exists wsman-datacollection-config.xml"

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file

  exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?

  if exists
    @current_resource.system_definition_file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    Chef::Log.debug "System definition exists wsman-datacollection-config.xml"
    return exists
  else
    exists = system_definition_exist_sub_folder?(sys_def_name)
  end
  Chef::Log.debug("dir search for system definition complete")
  exists
end

def system_definition_exist_sub_folder?(sys_def_name)
  Chef::Log.debug("Starting dir search for system definition")
  system_definition_file = shell_out("grep -l #{sys_def_name} #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if system_definition_file.stdout != '' && system_definition_file.stdout.lines.to_a.length == 1
      begin
        file = ::File.new("#{system_definition_file.stdout.chomp}", 'r')
        doc = REXML::Document.new file
        file.close

        exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?
        if exists
          Chef::Log.debug("file name for system definition #{system_definition_file.stdout.chomp}")
          @current_resource.system_definition_file_path = "#{system_definition_file.stdout.chomp}"
          return exists
        end
      end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for system definition name #{sys_def_name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |name|
      next if file !~ /.*\.xml$/
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{name}", 'r')
      doc = REXML::Document.new file
      file.close

      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?
      if exists
        @current_resource.system_definition_file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{name}"
        return exists
      end
    end
  end
end

def include_group_exists?(group_name)
  Chef::Log.debug "Checking to see if this ws-man include_group_exists: '#{group_name}'"

  #Check to see if group exist in wsman-datacollection-config.xml
  Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  exists = !doc.elements["/wsman-datacollection-config/system-definition/include-group[text() = '#{group_name}']"].nil?

  if exists
    @current_resource.include_group_file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    return exists
  else exists = include_group_exist_sub_folder?(group_name)
  end
  Chef::Log.debug("dir search for include group name #{group_name} complete")
  exists
end

def include_group_exist_sub_folder?(group_name)
# let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
  groupfile = shell_out("grep -l #{group_name} #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
  if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
    begin
      exists = include_group_in_file?(groupfile.stdout.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{groupfile.stdout.chomp}")
        @current_resource.include_group_file_path = "#{groupfile.stdout.chomp}"
        return exists
      end
    end
  else # if multiple files match, only return if true since could be a regex false positive.
    groupfile.stdout.lines.each do |file|
      exists = group_in_file?(file.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{file}")
        @current_resource.include_group_file_path = "#{file}"
        return exists
      end
    end
  end

  # okay, we'll do it right now, but this is slow.
  Chef::Log.debug("Starting dir search for included group name #{group_name}")
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
    next if file !~ /.*\.xml$/
    exists = include_group_in_file?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
    if exists
      @current_resource.include_group_file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}"
    end
    break if exists
  end
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
  system_definition_xpath = "/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"
  Chef::Log.debug "system_definition_xpath  is: #{system_definition_xpath}"
  system_definition_xpath
end

def group_file?(file, node)
  fn = "#{node['opennms']['conf']['home']}/etc/#{file}"
  groupfile = false
  if ::File.exist?(fn)
    file = ::File.new(fn, 'r')
    doc = REXML::Document.new file
    file.close
    groupfile = !doc.elements['/wsman-datacollection-config'].nil?
  end
  groupfile
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


