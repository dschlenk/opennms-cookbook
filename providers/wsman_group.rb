# frozen_string_literal: true
#
include ResourceType
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
    updated = create_wsman_group
    converge_by("Update #{@new_resource}") if updated
  else Chef::Log.info "#{@new_resource} doesn't exist - creating."
  converge_by("Create #{@new_resource}") do
    create_wsman_group
  end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else converge_by("Create if missing #{@new_resource}") do
    create_wsman_group
  end
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
  @current_resource.group_name(@new_resource.group_name || @new_resource.group_name)
  @current_resource.file(@new_resource.file)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_uri(@new_resource.resource_uri)
  @current_resource.dialect(@new_resource.dialect)
  @current_resource.filter(@new_resource.filter)
  @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}"

  if !group_file?(@new_resource.file, node)
    create_wsman_group_file
  end

  if group_exists?(@new_resource.group_name)
    Chef::Log.debug("group #{@current_resource.group_name} is in file already")
    @current_resource.exists = true
  end

end

private

def create_wsman_group_file ()
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new
  root_el = doc.add_element 'wsman-datacollection-config'
  sys_def_el = root_el.add_element 'system-definition'
  sys_def_el.attributes['name'] = "#{new_resource.group_name}"
  incl_def_el = sys_def_el.add_element 'include-group'
  incl_def_el.add_text("#{new_resource.group_name}")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
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
  end

  return if exists


  # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
  groupfile = shell_out("grep -l #{group_name} #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
  if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
    begin
      exists = group_in_file?(groupfile.stdout.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{groupfile.stdout.chomp}")
        @current_resource.file_path = "#{groupfile.stdout.chomp}"
      end
      return if exists
    end
  else # if multiple files match, only return if true since could be a regex false positive.
    groupfile.stdout.lines.each do |file|
      exists = group_in_file?(file.chomp, group_name)
      if exists
        Chef::Log.debug("file name #{file}")
        @current_resource.file_path = "#{file}"
      end
      return if exists
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
  Chef::Log.debug("dir search for group name #{group_name} complete")
  exists
end

def group_in_file?(file, group)
  Chef::Log.debug "Group in File : '#{file}'"
  file = ::File.new("#{file}", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements[group_xpath(group)].nil?
end

def group_xpath(group)
  group_xpath = "/wsman-datacollection-config/group[@name='#{group}']"
  Chef::Log.debug "group xpath is: #{group_xpath}"
  group_xpath
end

def create_wsman_group
  Chef::Log.debug "Creating wsman group : '#{new_resource.name}'"
  f = ::File.new("#{@current_resource.file_path}")
  Chef::Log.debug "file name : '#{new_resource.file}'"
  contents = f.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  last_group_el = doc.root.elements['/wsman-datacollection-config/system-definition/']
  first_group_el = !doc.elements['/wsman-datacollection-config/group[first()]'].nil? || doc.root.elements['/wsman-datacollection-config/']

  if new_resource.position == 'bottom'
    if !last_group_el.nil?
      begin
        doc.root.insert_before(last_group_el, REXML::Element.new('group'))
        group_el = doc.root.elements['/wsman-datacollection-config/group']
      end
    else begin
      doc.root.insert_after(first_group_el, REXML::Element.new('group'))
      group_el = doc.root.elements['/wsman-datacollection-config/group']
    end
    end
  else begin
    doc.root.insert_after(first_group_el, REXML::Element.new('group'))
    group_el = doc.root.elements['/wsman-datacollection-config/group']
  end
  end

  group_el.attributes['name'] = new_resource.group_name
  group_el.attributes['resource-uri'] = new_resource.resource_uri unless new_resource.resource_uri.nil?
  group_el.attributes['dialect'] = new_resource.dialect unless new_resource.dialect.nil?
  group_el.attributes['filter'] = new_resource.filter unless new_resource.filter.nil?
  group_el.attributes['resource-type'] = new_resource.resource_type unless new_resource.resource_type.nil?

  unless new_resource.attribs.nil?
    begin
      new_resource.attribs.each do |name, details|
        attrib_el = group_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'type' => details['type']
        attrib_el.add_attribute('index-of', details['index-of']) if details['index-of']
        attrib_el.add_attribute('filter', details['filter']) if details['filter']
      end
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{@current_resource.file_path}")
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

def delete_wsman_group() end
