# frozen_string_literal: true
module WsmanSystemDefinition
def groups_in_system_definition?(onms_home, system_definition_name, system_definition_file, groups)
    Chef::Log.debug "Checking to see if groups #{groups} exist in '#{system_definition_file}'"
    exists = true
    file = ::File.new("#{onms_home}/etc/wsman-datacollection.d/#{system_definition_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      if doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_definition_name}']/include-group[text() = '#{group}']"].nil?
        exists = false
        break
      end
    end
    exists
  end

  def group_exists?(onms_home, group)
    Chef::Log.debug "Checking to see if group #{group} exists."
    exists = false
    Dir.foreach("#{onms_home}/etc/wsman-datacollection.d") do |gf|
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

  def find_system_definition(onms_home, name)
    system_definition_file = nil
    Dir.foreach("#{onms_home}/etc/wsman-datacollection.d") do |group|
      next if group !~ /.*\.xml$/
      file = ::File.new("#{onms_home}/etc/wsman-datacollection.d/#{group}", 'r')
      doc = REXML::Document.new file
      file.close
      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
      if exists
        system_definition_file = group
        break
      end
    end
    system_definition_file
  end

  def add_groups(onms_home, groups, system_definition)
    system_definition_file = find_system_definition(onms_home, system_definition)
    file = ::File.new("#{onms_home}/etc/wsman-datacollection.d/#{system_definition_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      next unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_definition}']/include-group[text() = '#{group}']"].nil?
      collect_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_definition}']"]
      ig_el = collect_el.add_element 'include-group'
      ig_el.add_text group
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{system_definition_file}")
  end

  def remove_groups(onms_home, groups, system_definition)
    system_definition_file = find_system_definition(onms_home, system_definition)
    file = ::File.new("#{onms_home}/etc/wsman-datacollection.d/#{system_def_file}", 'r')
    doc = REXML::Document.new file
    file.close
    groups.each do |group|
      unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{system_definition}']/include-group[text() = '#{group}']"].nil?
        doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{system_definition}']/include-group[text() = '#{group}']"
      end
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{system_definition_file}")
  end
end
