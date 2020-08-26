# frozen_string_literal: true

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :add do
  Chef::Application.fatal!("Missing one of these data-collection groups: #{@current_resource.groups}.") unless @current_resource.groups_exist
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already in systemDef - nothing to do."
  else
    converge_by("Add #{@new_resource}") do
      add_groups_to_system_definition
    end
  end
end

action :remove do
  Chef::Application.fatal!("Missing one of these wsman data-collection groups: #{@current_resource.groups}.") unless @current_resource.groups_exist
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} not present - nothing to do."
  else
    converge_by("Remove #{@new_resource}") do
      remove_groups_from_system_definition
    end
  end
end
def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_system_def, node).new(@new_resource.name)
  @current_resource.groups(@new_resource.groups)

  ge = true
  @current_resource.groups.each do |group|
    next if group_exists?(group)
    Chef::Log.error "Missing data-collection group #{group}"
    ge = false
    break
  end
  @current_resource.groups_exist = true if ge
  system_def_file = find_system_def(@current_resource.name)
  unless @current_resource.file_path.nil?
    @current_resource.system_def_exists = true
    if groups_in_system_definition?(@current_resource.name, @current_resource.file_path, @current_resource.groups)
      @current_resource.exists = true
    end
  end
end


private

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
  system_def_file = @current_resource.file_path
  system_def_file
  end
end

def group_exists?(group)
  Chef::Log.debug "Checking to see if group #{group} exists."
  exists = false
  Dir.foreach("#{node['opennms']['conf']['home']}etc/wsman-datacollection.d") do |gf|
    next if gf !~ /.*\.xml$/
    file = ::File.new("#{onms_home}/etc/wsman-datacollection.d/#{gf}", 'r')
    doc = REXML::Document.new file
    file.close
    unless doc.elements["/wsman-datacollection-config/group[@name='#{group}']"].nil?
      exists = true
      break
    end
  end
  exists
end