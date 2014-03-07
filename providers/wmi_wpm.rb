def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing wmi-collection #{@current_resource.collection_name}.") if !@current_resource.collection_exists
  Chef::Application.fatal!("Missing resourceType #{@current_resource.resource_type}.") if !@current_resource.resource_type_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_wmi_wpm
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsWmiWpm.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.resource_type(@new_resource.resource_type)

  if collection_exists?(@current_resource.collection_name)
     @current_resource.collection_exists = true
  end
  if wpm_exists?(@current_resource.collection_name, @current_resource.name)
     @current_resource.exists = true
  end
#  rt = Chef::Resource::OpennmsResourceType.new(@new_resource.resource_type)
  
  exists, included = resource_type_exists_included(@current_resource.resource_type) #rt.resource_type_exists_included(@current_resource.resource_type)
  @current_resource.resource_type_exists = exists && included
end


private

# I'm sure there's a better way than copy/pasting these private methods from resource_type to figure out if it exists aleady.
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

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this wmi collection exists: '#{ collection_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{collection_name}']"].nil?
end

def wpm_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this wmi wpm exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{collection_name}']/wpms/wpm[@name='#{name}']"].nil?
end

def create_wmi_wpm
  Chef::Log.debug "Creating wmi wpm : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  wpms_el = doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{new_resource.collection_name}']/wpms"]
  wpm_el = wpms_el.add_element 'wpm', {'name' => new_resource.name, 'wmiClass' => new_resource.wmi_class, 'keyvalue' => new_resource.keyvalue, 'recheckInterval' => new_resource.recheck_interval, 'ifType' => new_resource.if_type }
  if new_resource.wmi_namespace
    wpm_el.add_attribute('wmiNamespace' => new_resource.wmi_namespace)
  end
  new_resource.attribs.each { |name,details|
    attrib_el = wpm_el.add_element 'attrib', { 'name' => name, 'alias' => details['alias'], 'wmiObject' => details['wmi_object'], 'type' => details['type'] }
    if details['maxval']
      attrib_el.add_attribute('maxval' => details['maxval'])
    end
    if details['minval']
      attrib_el.add_attribute('minval' => details['minval'])
    end
  }

  out = ""
  #doc.write(out,3)
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/wmi-datacollection-config.xml", "w"){ |file| file.puts(out) }
end
