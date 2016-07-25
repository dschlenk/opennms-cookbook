def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - updating collection files as necessary."
    updated = false
    if !new_resource.file.nil?
      f = cookbook_file new_resource.file do
        path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
        owner "root"
        group "root"
        mode 00644
      end
      updated = f.updated_by_last_action?
    end
    if updated
      converge_by("Update #{ @new_resource }") do
        restart_collectd
        new_resource.updated_by_last_action(true)
      end
    else
      new_resource.updated_by_last_action(false)
    end
  else
    converge_by("Create #{ @new_resource }") do
      create_snmp_collection_group
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSnmpCollectionGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  # Good enough for create but that's about it
  if group_exists?(@current_resource.collection_name, @current_resource.name)
     @current_resource.exists = true
  end
end

private

def group_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this snmp collection group exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/datacollection-config/snmp-collection[@name='#{collection_name}']/include-collection[@dataCollectionGroup='#{name}']"].nil?
end

def create_snmp_collection_group
  Chef::Log.debug "Adding snmp collection group: '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  file.close

  collection_el = doc.elements["/datacollection-config/snmp-collection[@name='#{new_resource.collection_name}']"]
  include_collection_el = collection_el.add_element 'include-collection', { 'dataCollectionGroup' => new_resource.name }
  if !new_resource.system_def.nil?
    system_def_el = include_collection_el.add_attribute('systemDef', new_resource.system_def)
  end
  new_resource.exclude_filters.each { |exclude_filter|
    exclude_filter_el = include_collection_el.add_element 'exclude-filter'
    exclude_filter_el.add_text(REXML::CData.new(exclude_filter))
  }
  if !new_resource.file.nil?
    cookbook_file new_resource.file do
      path "#{node['opennms']['conf']['home']}/etc/datacollection/#{new_resource.file}"
      owner "root"
      group "root"
      mode 00644
    end  
  end

  # Write out changed content to file
  out = ""
  #doc.write(out,3)
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "w"){ |file| file.puts(out) }
end

def restart_collectd
  file "#{node['opennms']['conf']['home']}/etc/datacollection-config.xml" do
    action :touch
  end
end
