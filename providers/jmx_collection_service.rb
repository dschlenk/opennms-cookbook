# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jmx_collection_service
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJmxCollectionService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.service_name(@new_resource.service_name)

  # Good enough for create/delete but that's about it
  if service_exists?(@current_resource.package_name, @current_resource.service_name, @current_resource.name)
    @current_resource.exists = true
  end
end

private

def service_exists?(package_name, service_name, name)
  Chef::Log.debug "Checking to see if this jmx collection service exists: '#{service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}']/parameter[@key='collection' and @value='#{name}']"].nil?
end

def create_jmx_collection_service
  Chef::Log.debug "Adding collection service: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
  service_el = package_el.add_element 'service', 'name' => new_resource.service_name, 'status' => new_resource.status, 'interval' => new_resource.interval
  unless new_resource.user_defined.nil?
    service_el.add_attribute('user-defined' => new_resource.user_defined)
  end
  service_el.add_element 'parameter', 'key' => 'collection', 'value' => new_resource.collection
  service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
  service_el.add_element 'parameter', 'key' => 'protocol', 'value' => new_resource.protocol
  service_el.add_element 'parameter', 'key' => 'urlPath', 'value' => new_resource.url_path
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
  # make sure we've got a collector service definition at the end of the file
  unless doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
    doc.elements['/collectd-configuration'].add_element 'collector', 'service' => new_resource.service_name, 'class-name' => 'org.opennms.netmgt.collectd.Jsr160Collector'
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end
