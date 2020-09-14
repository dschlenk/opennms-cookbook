# frozen_string_literal: true

module WsmanSystemDefinition
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

  def add_wsman_system_definition(node, current_resource)
    sys_def_element = system_definition_xpath(current_resource.name)
    system_def_file = findFilePath(node, sys_def_element, "#{current_resource.name}")
    if !system_def_file.nil?
      Chef::Log.debug "System definition exists in file: '#{system_def_file}'"

      f = ::File.new("#{system_def_file}")
      contents = f.read
      doc = REXML::Document.new(contents, respect_whitespace: :all)
      doc.context[:attribute_quote] = :quote

      current_resource.groups.each do |group|
        next unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{current_resource.name}']/include-group[text() = '#{group}']"].nil?
        system_definition_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{current_resource.name}']"]
        ig_el = system_definition_el.add_element 'include-group'
        ig_el.add_text group
      end
      Opennms::Helpers.write_xml_file(doc, "#{system_def_file}")
    end
  end

  def remove_wsman_system_definition(node, current_resource)
    sys_def_element = system_definition_xpath(current_resource.name)
    system_def_file = findFilePath(node, sys_def_element, "#{current_resource.name}")
    if !system_def_file.nil?
      file = ::File.new("#{system_def_file}", 'r')
      doc = REXML::Document.new file
      file.close
      groups = new_resource.groups

      groups.each do |group|
        unless doc.elements["/wsman-datacollection-config/system-definition[@name='#{current_resource.name}']/include-group[text() = '#{group}']"].nil?
          doc.delete_element "/wsman-datacollection-config/system-definition[@name='#{current_resource.name}']/include-group[text() = '#{group}']"
        end
      end
      Opennms::Helpers.write_xml_file(doc, "#{system_def_file}")
    end
  end

  def create_system_definition(filename, name)
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

    sys_def_el.attributes['name'] = "#{name}"
    sys_def_el.add_text("\n")
    Opennms::Helpers.write_xml_file(doc, "#{filename}")
  end
end