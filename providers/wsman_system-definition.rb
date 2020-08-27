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
    add_groups_to_system_definition
  end
end

action :remove do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else converge_by("Remove #{@new_resource}") do
    remove_groups_from_system_definition
  end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_system_def, node).new(@new_resource.name)
  @current_resource.groups(@new_resource.groups)
  @current_resource.file_name(@new_resource.file_name)
  @current_resource.position(@new_resource.position)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file_name}"


  if !file_exists?(@current_resource.file_name, "#{node['opennms']['conf']['home']}")
    create_system_definition_file
  end

  @current_resource.exists = false
  system_definition_file = find_system_definition("#{node['opennms']['conf']['home']}", @current_resource.name)

  if !system_definition_file.nil?
    @current_resource.exists = true
  end

  if !@current_resource.exists
    create_system_definition(@current_resource.file_path)
  end

  ge = true
  @current_resource.groups.each do |group|
    next if group_exists?(group)
    Chef::Log.error "Missing data-collection group #{group}"
    ge = false
    break
  end
  @current_resource.groups_exist = true if ge
  system_def_file = find_system_definition(@current_resource.name)
  if !system_def_file.nil?
    @current_resource.system_def_exists = true
    if groups_in_system_definition?(@current_resource.name, @current_resource.file_path, @current_resource.groups)
      @current_resource.exists = true
    end
  end
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

def create_system_definition_file

end

def create_system_definition(filename)
  root_el = doc.add_element 'wsman-datacollection-config'
  #sys_def_el = root_el.add_element 'system-definition'
  #sys_def_el.attributes['name'] = "#{new_resource.group_name}"
  #incl_def_el = sys_def_el.add_element 'include-group'
  #incl_def_el.add_text("#{new_resource.group_name}")
  root_el.add_text("\n")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
end

def find_system_definition(name)
  system_def_file = nil
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?

  if exists
    @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    system_def_file = @current_resource.file_path
    return system_def_file
  else Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}", 'r')
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
    if exists
      @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}"
      system_def_file = @current_resource.file_path
      return system_def_file
    end
  end
  end
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

def add_groups_to_system_definition
  file = ::File.new("#{@current_resource.file_path}", 'r')
  doc = REXML::Document.new file
  file.close
  groups.each do |group|
    next unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"].nil?
    system_definition_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"]
    ig_el = system_definition_el.add_element 'includeGroup'
    ig_el.add_text group
  end
  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")
end

def remove_groups_from_system_definition
    system_def_file = find_system_definition(new_resource.name)

    file = ::File.new("#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups = new_resource.groups

    groups.each do |group|
      unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_def}']/include-group[text() = '#{group}']"].nil?
        doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{system_def}']/include-group[text() = '#{group}']"
      end
    end
    Opennms::Helpers.write_xml_file(doc, "#{system_def_file}")
end


def find_system_definition(name)
  system_def_file = nil
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
  doc = REXML::Document.new file

  exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?

  if exists
    @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    system_def_file = @current_resource.file_path
    return system_def_file
  else
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}", 'r')
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
    if exists
      @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}"
      system_def_file = @current_resource.file_path
      return system_def_file
    end
  end
  system_def_file
  end
end

def group_exists?(group)
  Chef::Log.debug "Checking to see if group #{group} exists."
  exists = false
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d") do |gf|
    next if gf !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{gf}", 'r')
    doc = REXML::Document.new file
    file.close
    unless doc.elements["/wsman-datacollection-config/group[@name='#{group}']"].nil?
      exists = true
      break
    end
  end
  exists
end