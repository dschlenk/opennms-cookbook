# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    if @current_resource.changed
      Chef::Log.info "#{@new_resource} already exists - need to update."
      converge_by("Create #{@new_resource}") do
        update_poller_service
      end
    else
      Chef::Log.info "#{@new_resource} already exists - not changed."
    end
  else
    Chef::Log.info "#{@new_resource} doesn't exist - need to create."
    converge_by("Create #{@new_resource}") do
      create_poller_service
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_poller_service
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_poller_service, node).new(@new_resource.service_name || @new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.interval(@new_resource.interval)
  @current_resource.user_defined(@new_resource.user_defined)
  @current_resource.status(@new_resource.status)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.port(@new_resource.port) unless @new_resource.port.nil?
  @current_resource.parameters(@new_resource.parameters)
  @current_resource.class_name(@new_resource.class_name)

  if service_exists?(@current_resource.package_name, @current_resource.name)
    @current_resource.exists = true
    @current_resource.changed = true if service_changed?(@current_resource)
  end
end

private

def service_exists?(package_name, name)
  Chef::Log.debug "Checking to see if this poller service exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/poller-configuration/package[@name='#{package_name}']/service[@name='#{name}']"].nil?
end

def service_changed?(current_resource)
  Chef::Log.debug "Checking to see if this poller service has changed: '#{current_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml", 'r')
  doc = REXML::Document.new file
  service_el = doc.elements["/poller-configuration/package[@name='#{current_resource.package_name}']/service[@name='#{current_resource.name}']"]
  monitor_el = doc.elements["/poller-configuration/monitor[@service='#{current_resource.name}']"]
  return true if monitor_el.attributes['class-name'].to_s != current_resource.class_name.to_s
  curr_interval = nil
  curr_interval = service_el.attributes['interval'] unless service_el.nil?
  Chef::Log.debug "curr_interval: '#{curr_interval}'; interval: '#{current_resource.interval}'"
  return true if curr_interval.to_s != current_resource.interval.to_s
  curr_user_defined = service_el.attributes['user-defined']
  Chef::Log.debug "curr_user_defined: '#{curr_user_defined}'"
  return true if curr_user_defined.to_s != current_resource.user_defined.to_s
  curr_status = service_el.attributes['status']
  Chef::Log.debug "curr_status: '#{curr_status}'"
  return true if curr_status.to_s != current_resource.status.to_s
  tel = service_el.elements["parameter[@key = 'timeout']"]
  if tel.nil?
    Chef::Log.debug "timeout: '#{current_resource.timeout}'"
    return true unless current_resource.timeout.nil?
  else
    curr_timeout = tel.attributes['value']
    Chef::Log.debug "curr_timeout: '#{curr_timeout}'"
    return true if curr_timeout.to_s != current_resource.timeout.to_s
  end
  pel = service_el.elements["parameter[@key = 'port']"]
  if pel.nil?
    return true unless current_resource.port.nil?
  else
    curr_port = pel.attributes['value']
    Chef::Log.debug "curr_port: '#{curr_port}'"
    return true if curr_port.to_s != current_resource.port.to_s
  end
  curr_params = {}
  params_str = {}
  service_el.elements.each("parameter[@key != 'port' and @key != 'timeout']") do |p|
    val = p.attributes['value'].to_s # make a string outta whatever this was
    curr_params[p.attributes['key']] = val
  end
  if current_resource.parameters.is_a?(Hash)
    # make a version of params that has strings for both keys and values
    # just so we can compare without forcing certain param values to
    # be specific types
    current_resource.parameters.each do |k, v|
      params_str[k.to_s] = v.to_s
    end
    Chef::Log.debug "curr_params: '#{curr_params}'; params: #{params_str}"
    return true if !current_resource.parameters.nil? && curr_params != params_str
  elsif !curr_params.empty?
    # means we've got some parameters that aren't special, and we don't want any
    return true
  end
  false
end

def update_poller_service
  service_name = new_resource.service_name || new_resource.name
  Chef::Log.debug "Updating poller service: '#{service_name}' in package '#{new_resource.package_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  service_el = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{service_name}']"]
  monitor_el = doc.elements["/poller-configuration/monitor[@service='#{service_name}']"]

  service_el.attributes['interval'] = new_resource.interval
  service_el.attributes['user-defined'] = new_resource.user_defined
  service_el.attributes['status'] = new_resource.status
  monitor_el.attributes['class-name'] = new_resource.class_name

  # literally looking for false here, shut up rubocop
  # rubocop:disable Style/IfUnlessModifier
  if new_resource.parameters == false
    service_el.elements.delete_all 'parameter'
  end
  # rubocop:enable Style/IfUnlessModifier

  if new_resource.parameters.is_a?(Hash) && !new_resource.parameters.empty?
    # clear out all parameters
    service_el.elements.delete_all 'parameter'
    # add them back with new values
    new_resource.parameters.each do |key, value|
      service_el.add_element 'parameter', 'key' => key, 'value' => value
    end
  end

  # update / recover special case parameters
  unless new_resource.timeout.nil?
    timeout_el = service_el.elements["parameter[@key='timeout']"]
    if timeout_el.nil?
      service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
    else
      timeout_el.attributes['value'] = new_resource.timeout
    end
  end
  unless new_resource.port.nil?
    port_el = service_el.elements["parameter[@key='port']"]
    if port_el.nil?
      service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
    else
      port_el.attributes['value'] = new_resource.port
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
end

def create_poller_service
  service_name = new_resource.service_name || new_resource.name
  Chef::Log.debug "Adding poller service: '#{service_name}'"
  # Open file
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']"]
  first_downtime_el = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']/downtime[1]"]
  first_oc = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']/outage-calendar[1]"]
  Chef::Log.debug("first_oc: #{first_oc}")
  service_el = REXML::Element.new('service')
  service_el.attributes['name'] = service_name
  service_el.attributes['interval'] = new_resource.interval
  service_el.attributes['user-defined'] = new_resource.user_defined
  service_el.attributes['status'] = new_resource.status
  if !first_oc
    Chef::Log.debug("first_oc is false so adding #{service_name} before first downtime element")
    package_el.insert_before(first_downtime_el, service_el)
  else
    Chef::Log.debug("first_oc not nil so adding #{service_name} before first outage-calendar element")
    package_el.insert_before(first_oc, service_el)
  end
  unless new_resource.timeout.nil?
    service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
  end
  unless new_resource.port.nil?
    service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
  end
  if new_resource.parameters != false && new_resource.parameters.is_a?(Hash)
    new_resource.parameters.each do |key, value|
      service_el.add_element 'parameter', 'key' => key, 'value' => value
    end
  end
  if doc.elements["/poller-configuration/monitor[@service='#{service_name}']"].nil?
    last_monitor_el = doc.elements['/poller-configuration/monitor[last()]']
    new_mon_el = REXML::Element.new('monitor')
    new_mon_el.attributes['service'] = service_name
    new_mon_el.attributes['class-name'] = new_resource.class_name
    doc.root.insert_after(last_monitor_el, new_mon_el)
  else
    Chef::Log.warn 'Existing monitor service exists with possibly conflicting class name. Results not guaranteed.'
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
end

def delete_poller_service
  service_name = new_resource.service_name || new_resource.name
  Chef::Log.debug "Deleting poller service: '#{service_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  # Note: we purposefully don't delete the monitor element from the bottom since there could be other services in other packages using it
  deleted = doc.root.elements.delete("/poller-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{service_name}']")
  Chef::Log.debug "Deleted poller service #{deleted}."
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
end
