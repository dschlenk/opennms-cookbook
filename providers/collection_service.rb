# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_collection_service
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_collection_service, node).new(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.collection(@new_resource.collection)

  # Good enough for create/delete but that's about it
  if service_exists?(@current_resource.package_name,
                     @current_resource.collection,
                     @current_resource.name)
    @current_resource.exists = true
  end
end

private

def service_exists?(package_name, collection, name)
  Chef::Log.debug "Checking to see if this collection service exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{name}']/parameter[@key='collection' and @value='#{collection}']"].nil?
end

def create_collection_service
  sname = new_resource.service_name || new_resource.name
  Chef::Log.debug "Adding collection package: '#{new_resource.name}'"
  # Open file
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
  if new_resource.user_defined
    service_el.add_attribute('user-defined', new_resource.user_defined)
  end
  service_el.add_element 'parameter', 'key' => 'collection', 'value' => new_resource.collection
  unless new_resource.port.nil?
    service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
  end
  unless new_resource.timeout.nil?
    service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
  end
  unless new_resource.retry_count.nil?
    service_el.add_element 'parameter', 'key' => 'retry', 'value' => new_resource.retry_count
  end
  unless new_resource.thresholding_enabled.nil?
    service_el.add_element 'parameter', 'key' => 'thresholding-enabled', 'value' => new_resource.thresholding_enabled
  end
  unless new_resource.parameters.nil?
    new_resource.parameters.each do |k, v|
      service_el.add_element 'parameter', 'key' => k, 'value' => v
    end
  end
  if !first_oc
    package_el.add_element(service_el)
  else
    package_el.insert_before(first_oc, service_el)
  end
  # make sure we've got a service definition at the end of the file - might already exist tho.
  unless doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
    doc.elements['/collectd-configuration'].add_element 'collector', 'service' => new_resource.service_name, 'class-name' => new_resource.class_name
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end
