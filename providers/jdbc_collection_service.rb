# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and has not changed - nothing to do."
  else
    converge_by("Create/update #{@new_resource}") do
      create_jdbc_collection_service
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jdbc_collection_service
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_jdbc_collection_service
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJdbcCollectionService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource.collection(@new_resource.collection)
  @current_resource.interval(@new_resource.interval)
  @current_resource.user_defined(@new_resource.user_defined)
  @current_resource.status(@new_resource.status)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.retry_count(@new_resource.retry_count)
  @current_resource.thresholding_enabled(@new_resource.thresholding_enabled)
  @current_resource.driver(@new_resource.driver)
  @current_resource.user(@new_resource.user)
  @current_resource.password(@new_resource.password)
  @current_resource.port(@new_resource.port)
  @current_resource.url(@new_resource.url)

  if service_exists?(@current_resource.package_name, @current_resource.service_name, @current_resource.collection)
    @current_resource.exists = true
    @current_resource.changed = true if service_changed?(@current_resource)
  end
end

private

def service_exists?(package_name, service_name, collection)
  Chef::Log.debug "Checking to see if this jdbc collection service exists: '#{service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}' and parameter[@key='collection' and @value='#{collection}']]"].nil?
end

def service_changed?(service)
  Chef::Log.debug "Checking to see if this jdbc collection service changed: '#{service.service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  sel = doc.elements["/collectd-configuration/package[@name='#{service.package_name}']/service[@name='#{service.service_name}' and parameter[@key='collection' and @value='#{service.collection}']]"]
  unless service.interval.nil?
    ival = sel.attributes['interval']
    Chef::Log.debug "'#{ival}' == '#{service.interval}'"
    return true unless ival.to_s == service.interval.to_s
  end
  unless service.user_defined.nil?
    ud = sel.attributes['user-defined']
    Chef::Log.debug "'#{ud}' == '#{service.user_defined}'"
    return true unless ud.to_s == service.user_defined.to_s
  end
  unless service.status.nil?
    sts = sel.attributes['status']
    Chef::Log.debug "'#{sts}' == '#{service.status}'"
    return true unless sts.to_s == service.status.to_s
  end
  unless service.timeout.nil?
    to = sel.elements["parameter[@key = 'timeout']/@value"]
    Chef::Log.debug "'#{to}' == '#{service.timeout}'"
    return true unless to.to_s == service.timeout.to_s
  end
  unless service.retry_count.nil?
    rc = sel.elements["parameter[@key = 'retry']/@value"]
    Chef::Log.debug "'#{rc}' == '#{service.retry_count}'"
    return true unless rc.to_s == service.retry_count.to_s
  end
  unless service.thresholding_enabled.nil?
    te = sel.elements["parameter[@key = 'thresholding-enabled']/@value"]
    Chef::Log.debug "'#{te}' == '#{service.thresholding_enabled}'"
    return true unless te.to_s == service.thresholding_enabled.to_s
  end
  unless service.driver.nil?
    driver = sel.elements["parameter[@key = 'driver']/@value"]
    Chef::Log.debug "'#{driver}' == '#{service.driver}'"
    return true unless driver.to_s == service.driver.to_s
  end
  unless service.user.nil?
    user = sel.elements["parameter[@key = 'user']/@value"]
    Chef::Log.debug "'#{user}' == '#{service.user}'"
    return true unless user.to_s == service.user.to_s
  end
  unless service.password.nil?
    password = sel.elements["parameter[@key = 'password']/@value"]
    Chef::Log.debug "'#{password}' == '#{service.password}'"
    return true unless password.to_s == service.password.to_s
  end
  unless service.port.nil?
    port = sel.elements["parameter[@key = 'port']/@value"]
    Chef::Log.debug "'#{port}' == '#{service.port}'"
    return true unless port.to_s == service.port.to_s
  end
  unless service.url.nil?
    url = sel.elements["parameter[@key = 'url']/@value"]
    Chef::Log.debug "'#{url}' == '#{service.url}'"
    return true unless url.to_s == service.url.to_s
  end
  false
end

def delete_jdbc_collection_service
  Chef::Log.debug "Deleting collection service: '#{new_resource.service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  d = doc.elements.delete "/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"
  Chef::Log.debug "Deleted #{d}"
  doc.elements.delete "/collectd-configuration/collector[@service='#{new_resource.service_name}']"
  Chef::Log.debug "Deleted #{d}"
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

def create_jdbc_collection_service
  Chef::Log.debug "Adding collection service: '#{new_resource.service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  updating = false
  package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
  service_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"]
  if service_el.nil?
    status = new_resource.status || 'on'
    interval = new_resource.interval || 300_000
    service_el = package_el.add_element 'service', 'name' => new_resource.service_name, 'status' => status, 'interval' => interval
  else
    updating = true
    Chef::Log.debug "Updating #{service_el}"
  end
  if updating
    service_el.attributes['status'] = new_resource.status unless new_resource.status.nil?
    service_el.attributes['interval'] = new_resource.interval unless new_resource.interval.nil?
    service_el.attributes['user-defined'] = new_resource.user_defined unless new_resource.user_defined.nil?
    handle_optional_param('user', new_resource.user, service_el)
    handle_optional_param('password', new_resource.password, service_el)
    handle_optional_param('port', new_resource.port, service_el)
    handle_optional_param('url', new_resource.url, service_el)
    handle_optional_param('driver', new_resource.driver, service_el)
    service_el.elements["parameter[@key = 'timeout']"].attributes['value'] = new_resource.timeout unless new_resource.timeout.nil?
    service_el.elements["parameter[@key = 'retry']"].attributes['value'] = new_resource.retry_count unless new_resource.retry_count.nil?
    service_el.elements["parameter[@key = 'thresholding-enabled']"].attributes['value'] = new_resource.thresholding_enabled unless new_resource.thresholding_enabled.nil?
    Chef::Log.debug "Updated: #{service_el}"
  else
    ud = false
    ud = true if new_resource.user_defined
    service_el.attributes['user-defined'] = ud
    service_el.add_element 'parameter', 'key' => 'collection', 'value' => new_resource.collection
    service_el.add_element 'parameter', 'key' => 'user', 'value' => new_resource.user unless new_resource.user.nil?
    service_el.add_element 'parameter', 'key' => 'password', 'value' => new_resource.password unless new_resource.password.nil?
    service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port unless new_resource.port.nil?
    service_el.add_element 'parameter', 'key' => 'url', 'value' => new_resource.url unless new_resource.url.nil?
    service_el.add_element 'parameter', 'key' => 'driver', 'value' => new_resource.driver unless new_resource.driver.nil?
    service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout unless new_resource.timeout.nil?
    retry_count = new_resource.retry_count || 1
    service_el.add_element 'parameter', 'key' => 'retry', 'value' => retry_count
    te = false # default
    te = true if new_resource.thresholding_enabled
    service_el.add_element 'parameter', 'key' => 'thresholding-enabled', 'value' => te
  end
  driver_file = 'foo'
  Chef::Log.debug "driver_file is '#{new_resource.driver_file}'"
  driver_file = new_resource.driver_file unless new_resource.driver_file == '' || new_resource.driver_file.nil?
  cookbook_file "#{driver_file}_#{new_resource.name}" do
    source new_resource.driver_file
    path "#{node['opennms']['conf']['home']}/lib/#{new_resource.driver_file}"
    mode 00644
    owner 'root'
    group 'root'
    not_if { new_resource.driver_file.to_s == '' || new_resource.driver_file.nil? }
  end
  # make sure we've got a collector service definition at the end of the file
  unless doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
    doc.elements['/collectd-configuration'].add_element 'collector', 'service' => new_resource.service_name, 'class-name' => 'org.opennms.netmgt.collectd.JdbcCollector'
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

def handle_optional_param(param_name, param_value, service_el)
  unless param_value.nil?
    ue = service_el.elements["parameter[@key = '#{param_name}']"]
    if ue.nil?
      service_el.add_element 'parameter', 'key' => param_name, 'value' => param_value
    else
      service_el.elements["parameter[@key = '#{param_name}']"].attributes['value'] = param_value
    end
  end
end
