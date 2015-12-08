def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_xml_collection_service
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlCollectionService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.collection(@new_resource.collection)

  # Good enough for create/delete but that's about it
  if service_exists?(@current_resource.package_name, @current_resource.service_name, @current_resource.collection)
     @current_resource.exists = true
  end
end


private

def service_exists?(package_name, service_name, collection)
  Chef::Log.debug "Checking to see if this xml collection service exists: '#{ service_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}']/parameter[@key='collection' and @value='#{collection}']"].nil?
end

def create_xml_collection_service
  Chef::Log.debug "Adding collection service: '#{ new_resource.service_name }'"
  # Open file
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  file.close

  package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
  service_el = package_el.add_element 'service', { 'name' => new_resource.service_name, 'status' => new_resource.status, 'interval' => new_resource.interval }
  if new_resource.user_defined
    service_el.add_attribute('user-defined' => new_resource.user_defined)
  end
  collection_param_el = service_el.add_element 'parameter', { 'key' => 'collection', 'value' => new_resource.collection }
  if new_resource.port
    port_el = service_el.add_element 'parameter', { 'key' => 'port', 'value' => new_resource.port }
  end
  if new_resource.timeout
    timeout_el = service_el.add_element 'parameter', { 'key' => 'timeout', 'value' => new_resource.timeout }
  end
  if new_resource.retry_count
    retries_el = service_el.add_element 'parameter', { 'key' => 'retry', 'value' => new_resource.retry_count }
  end
  if !new_resource.thresholding_enabled.nil?
    thresh_enabled_el = service_el.add_element 'parameter', { 'key' => 'thresholding-enabled', 'value' => new_resource.thresholding_enabled }
  end
  # make sure we've got a service definition at the end of the file
  if !doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
    doc.elements["/collectd-configuration"].add_element 'collector', { 'service' => new_resource.service_name, 'class-name' => 'org.opennms.protocols.xml.collector.XmlCollector' }
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "w"){ |file| file.puts(out) }
end

def delete_xml_collection_service
  #TODO
end
