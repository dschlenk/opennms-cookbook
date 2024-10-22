# frozen_string_literal: true

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jmx_collection_service
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_jmx_collection_service
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  sname = @new_resource.service_name || @new_resource.name
  @current_resource = Chef::Resource.resource_for_node(:opennms_jmx_collection_service, node).new(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource.collection(@new_resource.collection)

  # Good enough for create/delete but that's about it
  if service_exists?(@current_resource.package_name, sname, @current_resource.collection)
    @current_resource.exists = true
  end
end

private

def service_exists?(package_name, service_name, collection_name)
  Chef::Log.debug "Checking to see if this jmx collection service exists: '#{service_name}' in package #{package_name} with collection #{collection_name}"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}']/parameter[@key='collection' and @value='#{collection_name}']"].nil?
end

def delete_jmx_collection_service
  sname = @new_resource.service_name || @new_resource.name
  Chef::Log.debug "Deleting collection service: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  doc.delete_element("/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{sname}' and parameter[@key='collection' and @value='#{new_resource.collection}']]")

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

def create_jmx_collection_service
  sname = new_resource.service_name || new_resource.name
  Chef::Log.debug "Adding collection service: '#{sname}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
  first_oc = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/outage-calendar[1]"]
  service_el = REXML::Element.new('service')
  service_el.attributes['name'] = sname
  service_el.attributes['interval'] = new_resource.interval
  service_el.attributes['status'] = new_resource.status
  unless new_resource.user_defined.nil?
    service_el.add_attribute('user-defined' => new_resource.user_defined)
  end
  if new_resource.url.nil?
    service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
    service_el.add_element 'parameter', 'key' => 'protocol', 'value' => new_resource.protocol
    service_el.add_element 'parameter', 'key' => 'urlPath', 'value' => new_resource.url_path
    service_el.add_element 'parameter', 'key' => 'rmiServerPort', 'value' => new_resource.rmi_server_port unless new_resource.rmi_server_port.nil?
    service_el.add_element 'parameter', 'key' => 'remoteJMX', 'value' => new_resource.remote_jmx if new_resource.remote_jmx.to_s == 'true'
  else
    service_el.add_element 'parameter', 'key' => 'url', 'value' => new_resource.url
  end
  service_el.add_element 'parameter', 'key' => 'username', 'value' => new_resource.username unless new_resource.username.nil?
  service_el.add_element 'parameter', 'key' => 'password', 'value' => new_resource.password unless new_resource.password.nil?
  service_el.add_element 'parameter', 'key' => 'factory', 'value' => new_resource.factory unless new_resource.factory.nil?
  service_el.add_element 'parameter', 'key' => 'collection', 'value' => new_resource.collection
  service_el.add_element 'parameter', 'key' => 'rrd-base-name', 'value' => new_resource.rrd_base_name
  service_el.add_element 'parameter', 'key' => 'ds-name', 'value' => new_resource.ds_name
  service_el.add_element 'parameter', 'key' => 'friendly-name', 'value' => new_resource.friendly_name
  if new_resource.timeout
    service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
  end
  if new_resource.retry_count
    service_el.add_element 'parameter', 'key' => 'retry', 'value' => new_resource.retry_count
  end
  unless new_resource.thresholding_enabled.nil?
    service_el.add_element 'parameter', 'key' => 'thresholding-enabled', 'value' => new_resource.thresholding_enabled
  end
  if !first_oc
    package_el.add_element(service_el)
  else
    package_el.insert_before(first_oc, service_el)
  end
  # make sure we've got a collector service definition at the end of the file
  unless doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
    doc.elements['/collectd-configuration'].add_element 'collector', 'service' => new_resource.service_name, 'class-name' => 'org.opennms.netmgt.collectd.Jsr160Collector'
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end
