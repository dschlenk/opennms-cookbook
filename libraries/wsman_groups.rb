# frozen_string_literal: true
require 'rexml/document'

module WsmanGroups
  include Chef::Mixin::ShellOut

  def group_exists_wsman_datacollection_config?(group_name, node)
    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?
  end

  def group_exists_wsman_datacollection_d?(group_name, node)
    # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
    groupfile = shell_out("grep -l #{group_name} #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
      return group_in_file(groupfile.stdout.chomp, group_name)
    else # if multiple files match, only return if true since could be a regex false positive.
      groupfile.stdout.lines.each do |file|
        return true if group_in_file(file.chomp, group_name)
      end
    end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for group name #{group_name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
      next if file !~ /.*\.xml$/
      exists = group_in_file("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
      break if exists
    end
    Chef::Log.debug("dir search for group name #{group_name} complete")
    exists
  end

  def group_in_file?(file_name, group_name)
    file_name = ::File.new(file_name, 'r')
    doc = REXML::Document.new file_name
    file_name.close
    !doc.elements[group_xpath(group_name)].nil?
  end

  def group_xpath(group_name)
    group_xpath = "/wsman-datacollection-config/group[@name='#{group_name}']"
    Chef::Log.debug "group xpath is: #{group_xpath}"
    group_xpath
  end

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

  def find_file_path?(group_name)
    file_path = nil
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
      next if file !~ /.*\.xml$/
      exists = group_in_file("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
      if exists
        file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}"
        break
      end
      file_path
    end
  end

  def group_changed?(file_path, group_name)
    file_name = ::File.new("#{file_path}", 'r')
    doc = REXML::Document.new file_name
    file_name.close

    group_el = doc.elements[group_xpath(group_name)]
    unless group_name.resource_uri.nil?
      el = group_el.elements['resource_uri'].text.to_s
      Chef::Log.debug "Group Resource Uri equal? New: #{group_name.resource_uri}; Current: #{el}"
      return true unless group_name.resource_uri == el
    end
    unless group_name.dialect.nil?
      dialect_el = group_el.elements['dialect'].text.to_s
      Chef::Log.debug "Group Dialect equal? New: #{group_name.dialect}; Current: #{dialect_el}"
      return true unless group_name.dialect == dialect_el
    end
    unless group_name.resource_type.nil?
      resource_Typ_el = group_el.elements['resource-type'].text.to_s
      Chef::Log.debug "Group Resource equal? New: #{group_name.resource_type}; Current: #{resource_Typ_el}"
      return true unless group_name.resource_type == resource_Typ_el
    end
    unless group_name.filter.nil?
      filter_el = group_el.elements['resource-type'].text.to_s
      Chef::Log.debug "Group Filter equal? New: #{group_name.filter}; Current: #{filter_el}"
      return true unless group_name.filter == filter_el
    end

    unless group_name.attribs.nil?
      if group_name.attribs.empty?
        unless group_el.elements['attribs'].nil?
          Chef::Log.debug 'Event attribs present but nil in new resource.'
          return true
        end
      end
      if group_el.elements['attribs'].nil?
        unless group_name.attribs.nil?
          Chef::Log.debug 'group attribs not present but not nil in new resource.'
          return true
        end
      else attribs = []
      group_el.elements.each('attribs') do |name, value|
        name = name.text.to_s
        value = value.text.to_s
        attribs.push "#{name}" => "#{value}"
      end
      end
      Chef::Log.debug "attribs equal? New: #{group_name.attrib}, current #{attribs}"
      return true unless group_name.attribs == attribs
    end
    Chef::Log.debug 'Nothing in this event has changed!'
    false
  end

  def remove_group(group, node)
    Chef::Log.debug "group is #{group}"
    file_name = nil
    file_path = nil
    if group_exists_wsman_datacollection_config?(group, node)
      file_name = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
      file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    else
      file_path = find_file_path?(group)
      file_name = ::File.new("#{file_path}", 'r')
    end

    contents = file_name.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote
    file_name.close

    group_el = matching_group(doc, new_resource)
    doc.root.delete(group_el)
    Opennms::Helpers.write_xml_file(doc, "#{file_path}")
  end

  def matching_group(doc, current_resource)
    doc.elements["/wsman-datacollection-config/group[@name='#{current_resource}']"]
  end
end
