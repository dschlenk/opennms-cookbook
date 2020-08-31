# frozen_string_literal: true

module WsmanGroup
  def created_wsman_group (current_resource, node)
    group_element = group_xpath("#{current_resource.group_name}")
    group_file = findFilePath(node, group_element, current_resource.group_name)
    if group_file.nil?
      Chef::Log.debug "Creating wsman group : #{current_resource.group_name}"
      f = ::File.new("#{current_resource.file_path}")
      Chef::Log.debug "file name : '#{current_resource.file_name}'"
      contents = f.read
      doc = REXML::Document.new(contents, respect_whitespace: :all)
      doc.context[:attribute_quote] = :quote

      if current_resource.position == 'top'
        #Check for first group in the file
        if !doc.elements['/wsman-datacollection-config/group[1]'].nil?
          group_el = REXML::Element.new 'group'
          first_group = doc.elements['/wsman-datacollection-config/group[1]']
          doc.root.insert_before(first_group, group_el)
        elsif !doc.root.elements['/wsman-datacollection-config/system-definition[1]'].nil?
          first_sys_def = doc.elements['/wsman-datacollection-config/system-definition[1]']
          group_el = REXML::Element.new 'group'
          doc.root.insert_before(first_sys_def, group_el)
        elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
          last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
          group_el = REXML::Element.new 'group'
          doc.root.insert_after(last_collection, group_el)
        else group_el = doc.root.add_element 'group'
        end
      else #add to bottom
        if !doc.elements['/wsman-datacollection-config/group[last()]'].nil?
          group_el = REXML::Element.new 'group'
          last_group = doc.elements['/wsman-datacollection-config/group[last()]']
          doc.root.insert_after(last_group, group_el)
        elsif !doc.root.elements['/wsman-datacollection-config/system-definition[1]'].nil?
          first_sys_def = doc.elements['/wsman-datacollection-config/system-definition[1]']
          group_el = REXML::Element.new 'group'
          doc.root.insert_before(first_sys_def, group_el)
        elsif !doc.root.elements['/wsman-datacollection-config/collection[last()]'].nil?
          last_collection = doc.root.elements['/wsman-datacollection-config/collection/[last()]']
          group_el = REXML::Element.new 'group'
          doc.root.insert_after(last_collection, group_el)
        else group_el = doc.root.add_element 'group'
        end
      end

      if !group_el.nil?
        group_el.attributes['name'] = current_resource.group_name
        group_el.attributes['resource-type'] = current_resource.resource_type
        group_el.attributes['resource-uri'] = current_resource.resource_uri

        unless current_resource.dialect.nil?
          group_el.attributes['dialect'] = current_resource.dialect
        end

        unless current_resource.filter.nil?
          group_el.attributes['filter'] = current_resource.filter
        end

        unless current_resource.attribs.nil?
          begin
            current_resource.attribs.each do |name, details|
              attrib_el = group_el.add_element 'attrib', 'name' => name, 'alias' => details['alias'], 'type' => details['type']
              attrib_el.add_attribute('index-of', details['index-of']) if details['index-of']
              attrib_el.add_attribute('filter', details['filter']) if details['filter']
            end
          end
        end
      end
      Opennms::Helpers.write_xml_file(doc, "#{current_resource.file_path}")
    end
  end

  def delete_group(group, name)
    Chef::Log.debug "delete group in file : '#{group}'"
    file = ::File.new("#{group}", 'r')
    doc = REXML::Document.new file
    file.close

    del_el = doc.elements.delete("/wsman-datacollection-config/group[@name='#{name}']")
    Chef::Log.debug("Deleted element: #{del_el}")

    Opennms::Helpers.write_xml_file(doc, "#{group}")
  end

  def delete_included_def(name)
    included_element = included_group_xpath(name)
    included_group = findFilePath(node, included_element, name)
    if !included_group.nil?
      Chef::Log.debug "included_group_in_file?: '#{included_group}'"

      file = ::File.new("#{included_group}", 'r')
      doc = REXML::Document.new file
      file.close

      del_el = doc.elements.delete("/wsman-datacollection-config/system-definition/include-group[text() = '#{name}']")
      Chef::Log.debug("Deleted include-group successfully: #{del_el}")

      Opennms::Helpers.write_xml_file(doc, "#{included_group}")
    end
  end


  def insert_included_def (name)
    Chef::Log.debug "No system definition included. Add system definition for : '#{name}'"

    sys_def_element = system_definition_xpath("#{name}")

    sys_def_file = findFilePath(node, sys_def_element, "#{name}")
    if !sys_def_file.nil?
      Chef::Log.debug "Current System Definition '#{name}' exist in: '#{sys_def_file}'"
      insert_system_definition_include_group(sys_def_file, name)
    end
  end

  def insert_system_definition_include_group(file_path, name)
    file = ::File.new("#{file_path}", 'r')
    doc = REXML::Document.new file
    file.close

    system_definition_el = doc.elements[system_definition_xpath(name)]


    if !system_definition_el.nil?
      Chef::Log.debug "Insert Include Group '#{name}' to existing system definition: '#{name}'"
      incl_def_el = system_definition_el.add_element 'include-group'
      incl_def_el.add_text("#{name}")
    end
    Opennms::Helpers.write_xml_file(doc, "#{file_path}")
  end

  #These function have not been tested yet. It need to test and refactoring when work on the change function
  def update_wsman_group(current_resource, node)
    #The change may have less or more attributes. it clean to delete the match group name then add new group with same name and new data
    Chef::Log.debug "file name : '#{current_resource.file_path}'"
    file = ::File.new(current_resource.file_path, 'r')
    doc = REXML::Document.new file
    file.close

    if group_in_file?(current_resource.file_path, current_resource.group_name)
      Chef::Log.debug "group_in_file?: 'true'"
      del_el = doc.elements.delete("/wsman-datacollection-config/group[@name='#{current_resource.group_name}']")
      Chef::Log.debug("Deleted element: #{del_el}")
    end

    Opennms::Helpers.write_xml_file(doc, "#{current_resource.file_path}")

    created_wsman_group(current_resource, node)
  end

  def group_in_file?(file, group)
    Chef::Log.debug "Group in File : '#{file}'"
    file = ::File.new("#{file}", 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements[group_xpath(group)].nil?
  end


  #Code below are not tested yet
  def group_equal?(current_resource)
    Chef::Log.debug "file name : '#{current_resource.file_path}'"
    file = ::File.new("#{current_resource.file_path}", 'r')
    doc = REXML::Document.new file
    file.close

    if group_in_file?("#{current_resource.file_path}", current_resource.group_name)
      Chef::Log.debug "group_in_file?: #{current_resource.file_path}"
      group_el = doc.elements["/wsman-datacollection-config/group[@name='#{current_resource.group_name}']"]
      return true if group_el.nil? && (current_resource.nil? || current_resource.empty?)

      if resource_type_equal?(group_el, current_resource) \
           && resource_uri_equal?(group_el, current_resource) \
           && dialect_equal?(group_el, current_resource) \
           && filters_equal?(group_el, current_resource) \
           && attribute_equal?(doc, current_resource)
        true
      else false
      end
    end
  end

  def resource_type_equal?(doc, current_resource)
    return true if doc.attributes['resource-type'].nil? && current_resource.resource_type.nil?

    Chef::Log.debug "resource_type_equal?: #{current_resource.resource_type}"
    doc.attributes['resource-type'].to_s == current_resource.resource_type.to_s
  end

  def resource_uri_equal?(doc, current_resource)
    return true if doc.attributes['resource-uri'].nil? && current_resource.resource_uri.nil?

    Chef::Log.debug "resource-uril?: #{current_resource.resource_uri}"
    doc.attributes['resource-uri'].to_s == current_resource.resource_uri.to_s
  end

  def dialect_equal?(doc, current_resource)
    return true if doc.attributes['dialect'].nil? && current_resource.dialect.nil?

    unless doc.attributes['dialect'].nil? && current_resource.dialect.nil?
      Chef::Log.debug "dialect_equal??: #{current_resource.dialect}"
      doc.attributes['dialect'].to_s == current_resource.dialect.to_s
    end
  end

  def filters_equal? (doc, current_resource)
    return true if doc.attributes['filter'].nil? && current_resource.filter.nil?

    unless doc.attributes['filter'].nil? && current_resource.filter.nil?
      Chef::Log.debug "filter_equal?: #{current_resource.filter}"
      doc.attributes['filter'].to_s == current_resource.filter.to_s
    end
  end

  def attribute_equal?(doc, current_resource)
    Chef::Log.debug "attribute_equal??: #{current_resource.attribs}"
    attribute_el = doc.elements["/wsman-datacollection-config/group[@name='#{current_resource.group_name}/attrib']"]
    return true if attribute_el.nil? && (current_resource.attribs.nil? || current_resource.attribs.empty?)

    unless current_resource.attribs.nil?
      begin
        current_resource.attribs.each do |name, details|
          group_el = doc.elements["/wsman-datacollection-config/group[@name='#{current_resource.group_name}']/attrib"]
          group_el.each do |att|
            return true if att.attribute['name'].nil? && name.nil?
            if att.attribute['name'] == name
              attrib_el = doc.elements["/wsman-datacollection-config/group[@name='#{current_resource.group_name}/attrib/[@name='#{name}']"]
              return true if attrib_el.nil? && (name.nil? || name.to_s == '')
              if alias_equal?(attrib_el, details['alias'])  \
              && type_equal?(attrib_el, details['type']) \
              && filter_equal?(attrib_el, details['filter']) \
              && index_of_equal?(attrib_el, details['index-of'])
              end
            end
          end
        end
      end
    end
  end

  def alias_equal?(doc, current_resource)
    return true if doc.attributes['alias'].nil? && current_resource.nil?
    Chef::Log.debug "alias_equal?: #{current_resource.to_s}"
    doc.attributes['alias'].to_s == current_resource.to_s
  end

  def type_equal?(doc, current_resource)
    return true if doc.attributes['type'].nil? && current_resource.nil?
    Chef::Log.debug "type?: #{current_resource.to_s}"
    doc.attributes['type'].to_s == current_resource.to_s
  end

  def filter_equal?(doc, current_resource)
    return true if doc.attributes['filter'].nil? && current_resource.nil?
    Chef::Log.debug "filter?: #{current_resource.to_s}"
    unless doc.attributes['filter'].nil? && current_resource.nil?
      doc.attributes['filter'].to_s == current_resource.to_s
    end
  end

  def index_of_equal?(doc, current_resource)
    return true if doc.attributes['index-of'].nil? && current_resource.nil?
    Chef::Log.debug "index-of?: #{current_resource.to_s}"
    unless doc.attributes['index-of'].nil? && current_resource.nil?
      doc.attributes['index-of'].to_s == current_resource.to_s
    end
  end
end