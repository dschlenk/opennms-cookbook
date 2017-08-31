# frozen_string_literal: true
module SystemDef
  def groups_in_system_def?(onms_home, system_def_name, system_def_file, groups)
    Chef::Log.debug "Checking to see if groups #{groups} exist in '#{system_def_file}'"
    exists = true
    file = ::File.new("#{onms_home}/etc/datacollection/#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      if doc.elements["/datacollection-group/systemDef[@name='#{system_def_name}']/collect/includeGroup[text() = '#{group}']"].nil?
        exists = false
        break
      end
    end
    exists
  end

  def group_exists?(onms_home, group)
    Chef::Log.debug "Checking to see if group #{group} exists."
    exists = false
    Dir.foreach("#{onms_home}/etc/datacollection") do |gf|
      next if gf !~ /.*\.xml$/
      file = ::File.new("#{onms_home}/etc/datacollection/#{gf}", 'r')
      doc = REXML::Document.new file
      file.close
      unless doc.elements["/datacollection-group/group[@name='#{group}']"].nil?
        exists = true
        break
      end
    end
    exists
  end

  def find_system_def(onms_home, name)
    system_def_file = nil
    Dir.foreach("#{onms_home}/etc/datacollection") do |group|
      next if group !~ /.*\.xml$/
      file = ::File.new("#{onms_home}/etc/datacollection/#{group}", 'r')
      doc = REXML::Document.new file
      file.close
      exists = !doc.elements["/datacollection-group/systemDef[@name='#{name}']"].nil?
      if exists
        system_def_file = group
        break
      end
    end
    system_def_file
  end

  def add_groups(onms_home, groups, system_def)
    system_def_file = find_system_def(onms_home, system_def)
    file = ::File.new("#{onms_home}/etc/datacollection/#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      next unless doc.elements["/datacollection-group/systemDef[@name='#{system_def}']/collect/includeGroup[text() = '#{group}']"].nil?
      collect_el = doc.elements["/datacollection-group/systemDef[@name='#{system_def}']/collect"]
      ig_el = collect_el.add_element 'includeGroup'
      ig_el.add_text group
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/datacollection/#{system_def_file}")
  end

  def remove_groups(onms_home, groups, system_def)
    system_def_file = find_system_def(onms_home, system_def)
    file = ::File.new("#{onms_home}/etc/datacollection/#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      unless doc.elements["/datacollection-group/systemDef[@name='#{system_def}']/collect/includeGroup[text() = '#{group}']"].nil?
        doc.delete_element "/datacollection-group/systemDef[@name='#{system_def}']/collect/includeGroup[text() = '#{group}']"
      end
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/datacollection/#{system_def_file}")
  end
end
