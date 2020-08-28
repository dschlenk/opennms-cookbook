# frozen_string_literal: true

include Wsman

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :add do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already in system-definition - nothing to do."
  else
    Chef::Log.info "#{@new_resource} doesn't exist - create new system definition."
    add_system_definition
  end
end

action :remove do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else converge_by("Remove #{@new_resource}") do
    remove_system_definition
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_wsman_system_definition, node).new(@new_resource.name)
  @current_resource.groups(@new_resource.groups)
  @current_resource.position(@new_resource.position)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"


  if !file_exists?("#{@new_resource.file_name}", node)
    create_file(node, @new_resource.file_name)
  end

  @current_resource.exists = false
  system_definition_name = @current_resource.name

  if !system_definition_name.nil?
    if system_definition_exist?(@current_resource.name, node)
      if groups_in_system_definition?(@current_resource.name, @current_resource.file_path, @current_resource.groups)
        @current_resource.exists = true
      end
    end
  end

  if !system_definition_exist?(@current_resource.name, node)
    create_system_definition("#{@current_resource.file_path}")
  end

  ge = true
  @current_resource.groups.each do |group|
    next if wsman_group_exists?("#{group}", node)
    Chef::Log.error "Missing data-collection group #{group}"
    ge = false
    break
  end
  @current_resource.group_exists = true if ge

end


private

def system_definition_file?(file, node)
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

def create_system_definition(filename)
  file = ::File.new("#{filename}", 'r')
  doc = REXML::Document.new file
  file.close

  if new_resource.position == 'top'
    #Check for first group in the file
    if !doc.elements['/wsman-datacollection-config/group[last()]'].nil?
      sys_def_el = REXML::Element.new 'system-definition'
      last_group_el = doc.elements['/wsman-datacollection-config/group[last()]']
      doc.root.insert_after(last_group_el, sys_def_el)
    elsif !doc.root.elements['/wsman-datacollection-config/system-definition[1]'].nil?
      first_sys_def_el = doc.elements['/wsman-datacollection-config/system-definition[1]']
      sys_def_el = REXML::Element.new 'system-definition'
      doc.root.insert_before(first_sys_def_el, sys_def_el)
    elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
      last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
      sys_def_el = REXML::Element.new 'system-definition'
      doc.root.insert_after(last_collection, sys_def_el)
    else
      sys_def_el = doc.root.add_element 'system-definition'
    end
  else
    #add to bottom
    if !doc.root.elements['/wsman-datacollection-config/system-definition[last()]'].nil?
      sys_def_el = REXML::Element.new 'system-definition'
      last_sys_def_el = doc.elements['/wsman-datacollection-config/system-definition[last()]']
      doc.root.insert_after(last_sys_def_el, sys_def_el)
    elsif !doc.elements['/wsman-datacollection-config/group[last()]'].nil?
      last_group_el = doc.elements['/wsman-datacollection-config/group[last()]']
      sys_def_el = REXML::Element.new 'system-definition'
      doc.root.insert_after(last_group_el, sys_def_el)
    elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
      last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
      sys_def_el = REXML::Element.new 'system-definition'
      doc.root.insert_after(last_collection, group_el)
    else
      sys_def_el = doc.root.add_element 'system-definition'
    end
  end

  sys_def_el.attributes['name'] = "#{new_resource.name}"
  sys_def_el.add_text("\n")
  Opennms::Helpers.write_xml_file(doc, "#{filename}")
end

def groups_in_system_definition?(system_def_name, system_def_file, groups)
  Chef::Log.debug "Checking to see if groups #{groups} exist in '#{system_def_file}'"
  exists = true
  file = ::File.new("#{system_def_file}", 'r')
  doc = REXML::Document.new file
  file.close
  groups.each do |group|
    if doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_def_name}']/include-group[text() = '#{group}']"].nil?
      exists = false
      break
    end
  end
  exists
end

def add_system_definition
  system_def_file = find_system_definition(node, "#{@current_resource.name}")
  Chef::Log.debug "System definition exists in file: '#{system_def_file}'"

  f = ::File.new("#{system_def_file}")
  contents = f.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  @current_resource.groups.each do |group|
    next unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"].nil?
    system_definition_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"]
    ig_el = system_definition_el.add_element 'include-group'
    ig_el.add_text group
  end
  Opennms::Helpers.write_xml_file(doc, "#{system_def_file}")
end

def remove_system_definition
    system_def_file = find_system_definition(node, "#{new_resource.name}")

    file = ::File.new("#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups = new_resource.groups

    groups.each do |group|
      unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"].nil?
        doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"
      end
    end
    Opennms::Helpers.write_xml_file(doc, "#{system_def_file}")
end