# frozen_string_literal: true

module WsmanCollection

  def wsman_service_exists?(name, node)
    Chef::Log.debug "Checking to see if this wsman collection exists: '#{name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/wsman-datacollection-config/collection[@name='#{name}']"].nil?
  end

  def created_wsman_collection (new_resource, node)
    Chef::Log.debug "Creating wsman collection : '#{new_resource.name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    contents = file.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote
    collection_el = doc.root.add_element 'collection', 'name' => new_resource.name
    rrd_el = collection_el.add_element 'rrd', 'step' => new_resource.rrd_step
    new_resource.rras.each do |rra|
      rra_el = rrd_el.add_element 'rra'
      rra_el.add_text(rra)
    end

    #Optional: The magic happens with the <include-all-system-definitions/> element which automatically includes all of the system definitions into the collection group.
    unless new_resource.include_system_definitions.nil?
      unless new_resource.include_system_definitions == true
        collection_el.add_element 'include-system-definitions'
      end
    end

    unless new_resource.include_system_definition.nil?
      new_resource.include_system_definition.each do |name|
        collection_el.add_element 'include-system-definition' => name
      end
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml")
  end
end