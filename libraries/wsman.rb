# frozen_string_literal: true
require 'rexml/document'
include Chef::Mixin::ShellOut

module Wsman
  def findFilePath(node, element, name)
    file = nil

    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if #{name} exists wsman-datacollection-config.xml"

    fn = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    if ::File.exist?(fn)
      exists = exists?(fn, element)
    end

    if exists
      file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      Chef::Log.debug "#{name} exists wsman-datacollection-config.xml"
      return file
    else
      file = search_in_sub_folder(node, element, name)
    end
    Chef::Log.debug("dir search for #{name} complete")
    file
  end

  def search_in_sub_folder(node, element, name)
    file = nil
    Chef::Log.debug("Starting dir search for #{name}")
    search_file = shell_out("grep -l '#{name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if search_file.stdout != '' && search_file.stdout.lines.to_a.length == 1
      begin
        exists = exists?("#{search_file.stdout.chomp}", element)
        if exists
          Chef::Log.debug("file name for system definition #{search_file.stdout.chomp}")
          file = "#{search_file.stdout.chomp}"
          return file
        end
      end
    else # if multiple files match, only return if true since could be a regex false positive.
      search_file.stdout.lines.each do |sfile|
        exists = exists?(sfile.chomp, element)
        if exists
          Chef::Log.debug("file name #{sfile}")
          file = "#{sfile}"
          return file
        end
      end
    end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for #{name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |filename|
      next if file !~ /.*\.xml$/

      exists = exists?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{filename}}", element)
      if exists
        file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{filename}"
        return file
      end
    end
    file
  end

  def exists?(filename, element)
    file = ::File.new("#{filename}", 'r')
    doc = REXML::Document.new file
    file.close

    exists = !doc.elements["#{element}"].nil?
    exists
  end

  def create_file(node, filename)
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new
    root_el = doc.add_element 'wsman-datacollection-config'
    root_el.add_text("\n")

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{filename}")
  end

  def included_group_xpath(name)
    include_group_xpath = "/wsman-datacollection-config/system-definition/include-group[text() = '#{name}']"
    Chef::Log.debug "group xpath is: #{include_group_xpath}"
    include_group_xpath
  end

  def group_xpath(name)
    group_xpath = "/wsman-datacollection-config/group[@name='#{name}']"
    Chef::Log.debug "group xpath is: #{name}"
    group_xpath
  end

  def config_file_xpath
    config_file_xpath = "/wsman-datacollection-config"
    Chef::Log.debug "config_file_xpath is wsman-datacollection-config"
    config_file_xpath
  end

  def system_definition_xpath(name)
    group_xpath = "/wsman-datacollection-config/system-definition[@name='#{name}']"
    Chef::Log.debug "group xpath is: #{name}"
    group_xpath
  end
end