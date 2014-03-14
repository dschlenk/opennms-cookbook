def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists && @current_resource.included
    Chef::Log.info "#{ @new_resource } already exists and is included - nothing to do."
  elsif @current_resource.exists
    Chef::Log.debug "#{ @new_resource } already exists - but not included."
    converge_by("Include #{ @new_resource }") do
      include_resource_type
      new_resource.updated_by_last_action(true)
    end
  else
    converge_by("Create #{ @new_resource }") do
      create_resource_type
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsResourceType.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.exists, @current_resource.included = resource_type_exists_included(@current_resource.name)
end

def resource_type_exists_included(name)
  Chef::Log.debug "Checking to see if this resource type exists: '#{ name }'"
  exists = false
  included = false
  group_name = find_resource_type(name)
  # check datacollection-config.xml to make sure the group is included in a snmp-collection
  if !group_name.nil?
    exists = true
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "r")
    doc = REXML::Document.new file
    file.close
    included = !doc.elements["/datacollection-config/snmp-collection/include-collection[@dataCollectionGroup='#{group_name}']"].nil?
  end
  [exists, included]
end

private

# returns the name of the group and the path of the file that contains resource_type 'name'.
def find_resource_type(name)
  group_name = nil
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/datacollection") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{group}", "r")
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/datacollection-group/resourceType[@name='#{name}']"].nil?
    if exists
      group_name = doc.elements["/datacollection-group"].attributes['name']
      break
    end 
  end
  group_name
end

# returns the path of the file that contains group 'name'
def find_group(name)
  file_name = nil
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/datacollection") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{group}", "r")
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/datacollection-group[@name='#{name}']"].nil?
    if exists
      file_name = "#{node['opennms']['conf']['home']}/etc/datacollection/#{group}"
      break
    end 
  end
  file_name
end


# resource type doesn't exist and isn't included. Group could exist, though. 
def create_resource_type
  Chef::Log.debug "Adding resource type: '#{ new_resource.name }'"
  outfile_name = "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml"
  doc = nil
  group_el = nil
  file_name = find_group(new_resource.group_name)
  # deal with the group existing but not the resource type
  if !file_name.nil?
    outfile_name = file_name
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml", "r")
    doc = REXML::Document.new file
    doc.context[:attribute_quote] = :quote
    file.close
    group_el = doc.elements["/datacollection-group[@name='#{new_resource.group_name}']"]
  #Dir.foreach("#{node['opennms']['conf']['home']}/etc/datacollection") do |group|
  #  next if group !~ /.*\.xml$/
  #  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{group}", "r")
  #  doc = REXML::Document.new file
  #  doc.context[:attribute_quote] = :quote
  #  file.close
  #  exists = !doc.elements["/datacollection-group[@name='#{new_resource.group_name}']"].nil?
  #  if exists
  ##    outfile_name = "#{node['opennms']['conf']['home']}/etc/datacollection/#{group}"
  #    group_el = doc.elements["/datacollection-group[@name='#{new_resource.group_name}']"]
  #    break
  #  end
  #end
  else #if group_el.nil? && (!::File.exists?("#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml") || ::File.zero?("#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.group_name}.xml"))
    doc = REXML::Document.new
    doc.context[:attribute_quote] = :quote
    doc << REXML::XMLDecl.new
    group_el = doc.add_element 'datacollection-group', { 'name' => new_resource.group_name }
  end
  type_el = group_el.add_element 'resourceType', { 'name' => new_resource.name, 'label' => new_resource.label }
  if new_resource.resource_label
    type_el.add_attribute( 'resourceLabel' => new_resource.resource_label )
  end
  persist_el = type_el.add_element 'persistenceSelectorStrategy', { 'class' => new_resource.persistence_selector_strategy }
  new_resource.persistence_selector_strategy_params.each { |param|
    persist_el.add_element 'parameter', { 'key' => param.keys[0], 'value' =>  param[param.keys[0]]}
  }
  storage_el = type_el.add_element 'storageStrategy', { 'class' => new_resource.storage_strategy }
  new_resource.storage_strategy_params.each { |param|
    storage_el.add_element 'parameter', { 'key' => param.keys[0], 'value' =>  param[param.keys[0]]}
  }
  
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open(outfile_name, "w"){ |file| file.puts(out) }
  # ensure there's an include-collection element in the default snmp-collection for this group
  opennms_snmp_collection_group new_resource.group_name do
    collection_name 'default'
  end
end

def include_resource_type
  # find the group name the resource_type exists in
  group_name = find_resource_type(new_resource.name)
  # add the group to the default snmp-collection
  opennms_snmp_collection_group group_name do
    collection_name 'default'
  end
end
