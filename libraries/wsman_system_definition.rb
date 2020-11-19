# frozen_string_literal: true

module WsmanSystemDefinition
  def groups_in_system_definition?(system_def_name, system_def_file, groups)
    Chef::Log.debug "Checking to see if groups #{groups} exist in '#{system_def_file}'"
    exists = true
    file = ::File.new(system_def_file, 'r')
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

  def add_wsman_system_definition(_node, file_path, new_resource)
    f = ::File.new(file_path)
    Chef::Log.debug "file name : '#{file_path}'"
    contents = f.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote

    Chef::Log.debug "Group '#{new_resource.groups}' are about to add to the system"
    system_definition_el = doc.root.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"]
    unless system_definition_el.nil?
      add_system_definition(doc, system_definition_el, new_resource)
      Opennms::Helpers.write_xml_file(doc, file_path)
    end
  end

  def remove_wsman_system_definition(file_name, new_resource)
    if groups_in_system_definition?(new_resource.name, file_name, new_resource.groups)
      f = ::File.new(file_name)
      Chef::Log.debug "Delete group in file: '#{file_name}'"
      contents = f.read
      doc = REXML::Document.new(contents, respect_whitespace: :all)
      doc.context[:attribute_quote] = :quote

      new_resource.groups.each do |group|
        unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"].nil?
          Chef::Log.debug "Delete group #{group} from file : '#{file_name}'"
          doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"
        end
      end
      # If empty system definition then remove system definition
      if doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[1]"].nil?
        Chef::Log.debug "Empty system definition detele system definition name #{new_resource.name} from file '#{file_name}'"
        doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']"
      end
      Opennms::Helpers.write_xml_file(doc, file_name)
    end
  end

  def create_system_definition(filename, new_resource)
    f = ::File.new(filename)
    Chef::Log.debug "file name : '#{filename}'"
    contents = f.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote

    if new_resource.position == 'top'
      # Check for first group in the file
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
    elsif new_resource.position == 'bottom'
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
    else
      Chef::Log.warn "Unknown position requested: '#{new_resource.position}' for '#{new_resource}'. Not doing anything."
    end

    sys_def_el.attributes['name'] = new_resource.name
    unless new_resource.groups.nil?
      add_system_definition(doc, sys_def_el, new_resource)
    end

    Opennms::Helpers.write_xml_file(doc, filename)
  end

  def add_system_definition(doc, system_definition, new_resource)
    new_resource.groups.each do |group|
      Chef::Log.debug "Group '#{group}' is about to add to the system"
      next unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{new_resource.name}']/include-group[text() = '#{group}']"].nil?
      # Check to see if group exist? If exist then add group to system definition. If not exist then return error
      group_element = group_xpath(group)
      included_group_file = find_file_path(node, group_element, group)
      if !included_group_file.nil?
        Chef::Log.debug "Group '#{group}' is added to the system"
        system_definition_el = system_definition.add_element 'include-group'
        system_definition_el.add_text group
      else
        Chef::Log.debug "Group '#{group}' is not exist in the system. Please ad group first"
      end
    end
  end
end
