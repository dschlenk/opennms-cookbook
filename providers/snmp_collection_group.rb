def whyrun_supported?
    true
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_snmp_collection_group
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_snmp_collection_group
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSnmpCollectionGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  # Good enough for create/delete but that's about it
  if group_exists?(@current_resource.collection_name, @current_resource.name)
     @current_resource.exists = true
  end
end

private

def group_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this snmp collection group exists: '#{ name }'"
  file = ::File.new("/opt/opennms/etc/datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/datacollection-config/snmp-collection[@name='#{collection_name}']/include-collection[@dataCollectionGroup='#{name}']"].nil?
end

def create_snmp_collection_group
  Chef::Log.debug "Adding snmp collection group: '#{ new_resource.name }'"
  # Open file
  file = ::File.new("/opt/opennms/etc/datacollection-config.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  file.close

  collection_el = doc.elements["/datacollection-config/snmp-collection[@name='#{new_resource.collection_name}']"]
  include_collection_el = collection_el.add_element 'include-collection', { 'dataCollectionGroup' => new_resource.name }
  # You can either specify a single systemDef, all systemDefs, or all systemDefs with exclusion regexs
  if new_resource.system_def
    system_def_el = include_collection_el.add_attribute('systemDef' => new_resource.system_def)
  else
    new_resource.exclude_filters.each { |exclude_filter|
      exclude_filter_el = include_collection_el.add_element 'exclude-filter'
      exclude_filter_el.add_text(REXML::CData.new(exclude_filter))
    }
  end
  cookbook_file new_resource.file do
    path "/opt/opennms/etc/datacollection/#{new_resource.file}"
    owner "root"
    group "root"
    mode 00644
  end  

  # Write out changed content to file
  out = ""
  #doc.write(out,3)
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("/opt/opennms/etc/datacollection-config.xml", "w"){ |file| file.puts(out) }
end

def delete_snmp_collection_group
  #TODO
end

