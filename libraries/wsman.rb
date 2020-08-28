# frozen_string_literal: true
include Chef::Mixin::ShellOut


module Wsman
  def find_system_definition(node, sys_def_name)
    system_definition_file = nil

    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if system definition exists wsman-datacollection-config.xml"

    fn = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
    if ::File.exist?(fn)
      file = ::File.new(fn, 'r')
      doc = REXML::Document.new file
      file.close
      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?
    end

    if exists
      system_definition_file="#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      Chef::Log.debug "System definition exists wsman-datacollection-config.xml"
      return system_definition_file
    else
      system_definition_file=find_system_definition_in_sub_folder(node, sys_def_name)
    end
    Chef::Log.debug("dir search for system definition complete")
    system_definition_file
  end

  def find_system_definition_in_sub_folder(node, sys_def_name)
    system_def_file = nil

    Chef::Log.debug("Starting dir search for system definition")
    system_definition_file=shell_out("grep -l '#{sys_def_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if system_definition_file.stdout != '' && system_definition_file.stdout.lines.to_a.length == 1
      begin
        file = ::File.new("#{system_definition_file.stdout.chomp}", 'r')
        doc = REXML::Document.new file
        file.close

        exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?
        if exists
          Chef::Log.debug("file name for system definition #{system_definition_file.stdout.chomp}")
          system_def_file = "#{system_definition_file.stdout.chomp}"
          return system_def_file
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
          system_def_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{name}"
          return system_def_file
        end
      end
    end
    system_def_file
  end

  def find_wsman_group(node, group_name)
    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file

    exists = !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?
    group_file = nil
    if exists
      group_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      return group_file
    else group_file = find_wsman_group_in_sub_folder(node, group_name)
    end
    Chef::Log.debug("dir search for group name #{group_name} complete")
    group_file
  end

  def find_wsman_group_in_sub_folder(node, group_name)
    group_in_file = nil

    # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
    groupfile = shell_out("grep -l '#{group_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
      begin
        exists = group_in_file?(groupfile.stdout.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{groupfile.stdout.chomp}")
          group_in_file = "#{groupfile.stdout.chomp}"
          return group_in_file
        end
      end
    else # if multiple files match, only return if true since could be a regex false positive.
      groupfile.stdout.lines.each do |file|
        exists = group_in_file?(file.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{file}")
          group_in_file = "#{file}"
          return group_in_file
        end
      end
    end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for group name #{group_name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
      next if file !~ /.*\.xml$/
      exists = group_in_file?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
      if exists
        group_in_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}"
        return group_in_file
      end
    end
    group_in_file
  end

  def find_include_group(node, group_name)
    include_group_file = nil
    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    exists = !doc.elements["/wsman-datacollection-config/system-definition/include-group[text() = '#{group_name}']"].nil?

    if exists
      include_group_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      return include_group_file
    else include_group_file = find_include_group_in_sub_folder(node, group_name)
    end
    Chef::Log.debug("dir search for include group name #{group_name} complete")
    include_group_file
  end

  def find_include_group_in_sub_folder(node, group_name)
    include_group_file = nil
    # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
    groupfile = shell_out("grep -l '#{group_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
      begin
        exists = include_group_in_file?(groupfile.stdout.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{groupfile.stdout.chomp}")
          include_group_file = "#{groupfile.stdout.chomp}"
          return include_group_file
        end
      end
    else # if multiple files match, only return if true since could be a regex false positive.
      groupfile.stdout.lines.each do |file|
        exists = group_in_file?(file.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{file}")
          include_group_file = "#{file}"
          return include_group_file
        end
      end
    end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for included group name #{group_name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
      next if file !~ /.*\.xml$/
      exists = include_group_in_file?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
      if exists
        include_group_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}"
        return include_group_file
      end
    end
    include_group_file
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

  def file_exists?(file, node)
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

  def create_file(node)
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new
    root_el = doc.add_element 'wsman-datacollection-config'
    root_el.add_text("\n")

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{@current_resource.file_name}")
  end

  def wsman_group_exists?(group_name, node)
    Chef::Log.debug "Checking to see if this ws-man group exists: '#{group_name}'"

    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    exists = !doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']"].nil?

    if exists
      return exists
    else exists = group_exist_sub_folder?(group_name, node)
    end
    Chef::Log.debug("dir search for group name #{group_name} complete")
    exists
  end

  def group_exist_sub_folder?(group_name, node) # let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
    groupfile = shell_out("grep -l '#{group_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
      begin
        exists = group_in_file?(groupfile.stdout.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{groupfile.stdout.chomp}")
          return exists
        end
      end
    else # if multiple files match, only return if true since could be a regex false positive.
      groupfile.stdout.lines.each do |file|
        exists = group_in_file?(file.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{file}")
          return exists
        end
      end
    end

    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for group name #{group_name}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/") do |file|
      next if file !~ /.*\.xml$/
      exists = group_in_file?("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{file}", group_name)
      break if exists
    end
  end

  def system_definition_exist?(sys_def_name, node)
    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if system definition exists wsman-datacollection-config.xml"

    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file

    exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?

    if exists
      @current_resource.system_definition_file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      Chef::Log.debug "System definition exists wsman-datacollection-config.xml"
      return exists
    else exists = system_definition_exist_sub_folder?(sys_def_name, node)
    end
    Chef::Log.debug("dir search for system definition complete")
    exists
  end

  def system_definition_exist_sub_folder?(sys_def_name, node)
    Chef::Log.debug("Starting dir search for system definition")
    system_definition_file = shell_out("grep -l '#{sys_def_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if system_definition_file.stdout != '' && system_definition_file.stdout.lines.to_a.length == 1
      begin
        file = ::File.new("#{system_definition_file.stdout.chomp}", 'r')
        doc = REXML::Document.new file
        file.close

        exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{sys_def_name}']"].nil?
        if exists
          Chef::Log.debug("file name for system definition #{system_definition_file.stdout.chomp}")
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
        return if exists
      end
    end
  end
  def include_group_exists?(group_name, node)
    Chef::Log.debug "Checking to see if this ws-man include_group_exists: '#{group_name}'"

    #Check to see if group exist in wsman-datacollection-config.xml
    Chef::Log.debug "Checking to see if this ws-man group exists wsman-datacollection-config.xml: '#{group_name}'"

    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    exists = !doc.elements["/wsman-datacollection-config/system-definition/include-group[text() = '#{group_name}']"].nil?

    if exists
      return exists
    else
      exists = include_group_exist_sub_folder?(group_name, node)
    end
    Chef::Log.debug("dir search for include group name #{group_name} complete")
    exists
  end

  def include_group_exist_sub_folder?(group_name, node)
# let's cheat! If can't find in the wsman-datacollection-config.xml then look for the group file in wsman-datacollection.d
    groupfile = shell_out("grep -l '#{group_name}' #{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/*.xml")
    if groupfile.stdout != '' && groupfile.stdout.lines.to_a.length == 1
      begin
        exists = include_group_in_file?(groupfile.stdout.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{groupfile.stdout.chomp}")
          return exists
        end
      end
    else
      # if multiple files match, only return if true since could be a regex false positive.
      groupfile.stdout.lines.each do |file|
        exists = group_in_file?(file.chomp, group_name)
        if exists
          Chef::Log.debug("file name #{file}")
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
        break
      end
    end
  end
end