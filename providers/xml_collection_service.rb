def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{ @new_resource } already exists and has not changed - nothing to do."
  else
    converge_by("Create/update #{ @new_resource }") do
      create_xml_collection_service
      new_resource.updated_by_last_action(true)
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_xml_collection_service
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      delete_xml_collection_service
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "#{ @new_resource } does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlCollectionService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.collection(@new_resource.collection)
  @current_resource.interval(@new_resource.interval)
  @current_resource.user_defined(@new_resource.user_defined)
  @current_resource.status(@new_resource.status)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.retry_count(@new_resource.retry_count)
  @current_resource.port(@new_resource.port)
  @current_resource.thresholding_enabled(@new_resource.thresholding_enabled)

  if service_exists?(@current_resource.package_name, @current_resource.service_name, @current_resource.collection)
     @current_resource.exists = true
     if service_changed?(@current_resource)
       @current_resource.changed = true
     end
  end
end


private

def service_exists?(package_name, service_name, collection)
  Chef::Log.debug "Checking to see if this xml collection service exists: '#{ service_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}' and parameter[@key = 'collection' and @value='#{collection}']]"].nil?
end

def service_changed?(service)
  Chef::Log.debug "Checking to see if this xml collection service changed: '#{ service.service_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "r")
  doc = REXML::Document.new file
  sel = doc.elements["/collectd-configuration/package[@name='#{service.package_name}']/service[@name='#{service.service_name}' and parameter[@key='collection' and @value='#{service.collection}']]"]
  unless service.interval.nil?
    ival = sel.attributes['interval']
    return true unless "#{ival}" == "#{service.interval}"
  end
  unless service.user_defined.nil?
    ud = sel.attributes['user-defined']
    return true unless "#{ud}" == "#{service.user_defined}"
  end
  unless service.status.nil?
    sts = sel.attributes['status']
    return true unless "#{sts}" == "#{service.status}"
  end
  unless service.timeout.nil?
    to = sel.elements["parameter[@key = 'timeout']/@value"]
    return true unless "#{to}" == "#{service.timeout}"
  end
  unless service.retry_count.nil?
    rc = sel.elements["parameter[@key = 'retry']/@value"]
    return true unless "#{rc}" == "#{service.retry_count}"
  end
  unless service.thresholding_enabled.nil?
    te = sel.elements["parameter[@key = 'thresholding-enabled']/@value"]
    return true unless "#{te}" == "#{service.thresholding_enabled}"
  end
  unless service.port.nil?
    port = sel.elements["parameter[@key = 'port']/@value"]
    return true unless "#{port}" == "#{service.port}"
  end
end

def delete_xml_collection_service
  Chef::Log.debug "Deleting collection service: '#{ new_resource.service_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close
  d = doc.elements.delete "/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"
  Chef::Log.debug "Deleted #{d}"
  d = doc.elements.delete "/collectd-configuration/collector[@service='#{new_resource.service_name}']"
  Chef::Log.debug "Deleted #{d}"
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "w"){ |file| file.puts(out) }
end

def create_xml_collection_service
  Chef::Log.debug "Adding collection service: '#{ new_resource.service_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  file.close

  updating = false
  package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
  service_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"]
  if service_el.nil?
    Chef::Log.debug "could not find existing service_el."
    status = new_resource.status || 'on'
    interval = new_resource.interval || 300000
    service_el = package_el.add_element 'service', { 'name' => new_resource.service_name, 'status' => status, 'interval' => interval }
  else
    Chef::Log.debug "found existing service_el: #{service_el}"
    updating = true
  end
  if updating
    service_el.attributes['status'] = new_resource.status unless new_resource.status.nil?
    service_el.attributes['interval'] = new_resource.interval unless new_resource.interval.nil?
    service_el.attributes['user-defined'] = new_resource.user_defined unless new_resource.user_defined.nil?
    service_el.elements["parameter[@key = 'timeout']"].attributes['value'] = new_resource.timeout unless new_resource.timeout.nil?
    service_el.elements["parameter[@key = 'retry']"].attributes['value'] = new_resource.retry_count unless new_resource.retry_count.nil?
    service_el.elements["parameter[@key = 'thresholding-enabled']"].attributes['value'] = new_resource.thresholding_enabled  unless new_resource.thresholding_enabled.nil?
    unless new_resource.port.nil?
      port_el = service_el.elements["parameter[@key = 'port']"]
      if port_el.nil?
        service_el.add_element 'parameter', { 'key' => 'port', 'value' => new_resource.port }
      else
        port_el.attributes['value'] = new_resource.port
      end
    end
  else
    ud = false
    ud = true if new_resource.user_defined
    service_el.attributes['user-defined'] = ud
    service_el.add_element 'parameter', { 'key' => 'collection', 'value' => new_resource.collection }
    service_el.add_element 'parameter', { 'key' => 'timeout', 'value' => new_resource.timeout } unless new_resource.timeout.nil?
    retry_count = new_resource.retry_count || 1
    service_el.add_element 'parameter', { 'key' => 'retry', 'value' => retry_count }
    service_el.add_element 'parameter', { 'key' => 'port', 'value' => new_resource.port } unless new_resource.port.nil?
    te = false # default
    te = true if new_resource.thresholding_enabled
    service_el.add_element 'parameter', { 'key' => 'thresholding-enabled', 'value' => te }
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
