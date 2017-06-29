# frozen_string_literal: true
module OpennmsXml
  def collection_exists?(node, collection_name, type = 'snmp')
    Chef::Log.debug "Checking to see if this #{type} collection exists: '#{collection_name}'"
    root_el_prefix = ''
    root_el_prefix = "#{type}-" unless type == 'snmp'
    file = if type == 'snmp'
             ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", 'r')
           else
             ::File.new("#{node['opennms']['conf']['home']}/etc/#{type}-datacollection-config.xml", 'r')
           end
    doc = REXML::Document.new file
    xpath = "/#{root_el_prefix}datacollection-config/#{type}-collection[@name='#{collection_name}']"
    Chef::Log.debug("Checking #{doc} for xpath #{xpath}")
    !doc.elements[xpath].nil?
  end

  def source_el(doc, resource, delete = false)
    url = resource.url || resource.name
    Chef::Log.debug("url is #{url}")
    xpath = "/xml-datacollection-config/xml-collection[@name='#{resource.collection_name}']/xml-source[@url='#{url}'"
    unless resource.request_method.nil?
      xpath = "#{xpath} and request[@method='#{resource.request_method}']"
    end
    unless resource.request_params.nil?
      resource.request_params.each do |k, v|
        xpath = "#{xpath} and request/parameter[@name='#{k}' and @value='#{v}']"
      end
    end
    unless resource.request_headers.nil?
      resource.request_headers.each do |k, v|
        xpath = "#{xpath} and request/header[@name='#{k}' and @value='#{v}']"
      end
    end
    unless resource.import_groups.nil?
      resource.import_groups.each do |ig|
        xpath = "#{xpath} and import-groups[text()='xml-datacollection/#{ig}']"
      end
    end
    xpath = "#{xpath}]"
    Chef::Log.debug("Checking for XPath '#{xpath}' against document " + doc.to_s)
    source_el = doc.root.elements[xpath]
    Chef::Log.debug("found? #{source_el}")
    doc.root.elements.delete(xpath) if !source_el.nil? && delete
    source_el
  end

  def xml_source_exists?(node, resource)
    Chef::Log.debug "Checking to see if this xml source exists: '#{resource.url}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    !source_el(doc, resource).nil?
  end

  def xml_group_el(doc, resource, delete = false)
    group_name = resource.group_name || resource.name
    xpath = "/xml-datacollection-config/xml-collection[@name='#{resource.collection_name}']/xml-source[@url='#{resource.source_url}']/xml-group[@name='#{group_name}']"
    Chef::Log.debug("Checking for XPath '#{xpath}' against document " + doc.to_s)
    group_el = doc.elements[xpath]
    Chef::Log.debug("found? #{group_el}")
    doc.root.elements.delete(xpath) if !group_el.nil? && delete
    group_el
  end

  # assumes xml_source exists
  def xml_group_exists?(node, resource)
    exists = false
    Chef::Log.debug "Checking to see if this xml group exists: '#{resource.group_name}'"
    # look in main file first
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
    doc = REXML::Document.new file

    group_el = xml_group_el(doc, resource)
    Chef::Log.debug("xml_group_el returned #{group_el}")
    return true unless group_el.nil?
    # look in included files
    import_els = doc.elements["/xml-datacollection-config/xml-collection[@name='#{resource.collection_name}']/xml-source[@url='#{resource.source_url}']/import-groups"]
    unless import_els.nil?
      import_els.each do |import_cdata|
        include_file = import_cdata.to_s
        # next if include_file !~ /.*\.xml$/
        # we're assuming that the include file follows every example ever and is relative to $onms_home/etc/
        file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{include_file}", 'r')
        doc = REXML::Document.new file
        file.close
        exists = !doc.elements["/xml-groups/xml-group[@name='#{resource.group_name}']"].nil?
        break if exists
      end
    end
    exists
  end
end
