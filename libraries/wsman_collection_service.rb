# frozen_string_literal: true

module WsmanCollectionService
  def service_exists?(package_name, collection, service_name)
    Chef::Log.debug "Checking to see if this wsman collection service exists: '#{service_name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
    doc = REXML::Document.new file
    !doc.elements["/collectd-configuration/package[@name='#{package_name}']/service[@name='#{service_name}']/parameter[@key='collection' and @value='#{collection}']"].nil?
  end

  def created_wsman_collection_service(new_resource, node)
    Chef::Log.debug "Adding wsman collection package: '#{new_resource.service_name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
    contents = file.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    file.close

    package_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']"]
    first_oc = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/outage-calendar[1]"]
    service_el = REXML::Element.new('service')
    service_el.attributes['name'] = new_resource.service_name
    service_el.attributes['interval'] = new_resource.interval
    service_el.attributes['status'] = new_resource.status

    unless new_resource.user_defined.nil?
      service_el.add_attribute('user-defined', new_resource.user_defined)
    end

    service_el.add_element 'parameter', 'key' => 'collection', 'value' => new_resource.collection
    if new_resource.port
      service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
    end
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
    # make sure we've got a service definition at the end of the file
    unless doc.elements["/collectd-configuration/collector[@service='#{new_resource.service_name}']"]
      doc.elements['/collectd-configuration'].add_element 'collector', 'service' => new_resource.service_name, 'class-name' => 'org.opennms.netmgt.collectd.WsManCollector'
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  end

  def service_changed?(new_resource, node)
    Chef::Log.debug "Checking to see if this wsman collection service has changed: '#{new_resource.service_name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
    doc = REXML::Document.new file
    service_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"]
    old_interval = service_el.attributes['interval']
    Chef::Log.debug "checking interval: #{old_interval} != #{new_resource.interval} ?"
    return true if old_interval.to_s != new_resource.interval.to_s
    old_user_defined = service_el.attributes['user-defined']
    Chef::Log.debug 'checking user-defined'
    return true if old_user_defined.to_s != new_resource.user_defined.to_s
    old_status = service_el.attributes['status']
    Chef::Log.debug 'checking status'
    return true if old_status.to_s != new_resource.status.to_s
    old_timeout = service_el.elements["parameter[@key='timeout']"]
    old_timeout = old_timeout.attributes['value'] unless old_timeout.nil?
    Chef::Log.debug 'checking timeout'
    return true if old_timeout.to_s != new_resource.timeout.to_s
    old_retry_count = service_el.elements["parameter[@key='retry']"]
    unless old_retry_count.nil?
      old_retry_count = old_retry_count.attributes['value']
    end
    Chef::Log.debug 'checking retry'
    return true if old_retry_count.to_s != new_resource.retry_count.to_s
    old_port = service_el.elements["parameter[@key='port']"]
    old_port = old_port.attributes['value'] unless old_port.nil?
    Chef::Log.debug 'checking port'
    return true if old_port.to_s != new_resource.port.to_s
    old_te = service_el.elements["parameter[@key='thresholding-enabled']"]
    old_te = old_te.attributes['value'] unless old_te.nil?
    Chef::Log.debug 'checking thresholding-enabled'
    return true if old_te.to_s != new_resource.thresholding_enabled.to_s
    Chef::Log.debug 'not changed!'
    false
  end

  def updated_wsman_collection_service(new_resource, node)
    Chef::Log.debug "Updating wsman collection service: '#{new_resource.service_name}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
    contents = file.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    file.close

    service_el = doc.elements["/collectd-configuration/package[@name='#{new_resource.package_name}']/service[@name='#{new_resource.service_name}' and parameter[@key='collection' and @value='#{new_resource.collection}']]"]
    service_el.attributes['status'] = new_resource.status
    service_el.attributes['interval'] = new_resource.interval
    if new_resource.user_defined.nil? && !service_el.attributes['user-defined'].nil?
      service_el.attributes.delete('user-defined')
    elsif !new_resource.user_defined.nil?
      service_el.attributes['user-defined'] = new_resource.user_defined # adds or changes
    end

    port_el = service_el.elements["parameter[@key='port']"]
    if new_resource.port.nil? && !port_el.nil?
      service_el.delete port_el
    elsif !new_resource.port.nil?
      if port_el.nil?
        service_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
      else
        port_el.attributes['value'] = new_resource.port
      end
    end

    timeout_el = service_el.elements["parameter[@key='timeout']"]
    if new_resource.timeout.nil? && !timeout_el.nil?
      service_el.delete timeout_el
    elsif !new_resource.timeout.nil?
      if timeout_el.nil?
        service_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
      else
        timeout_el.attributes['value'] = new_resource.timeout
      end
    end

    retry_el = service_el.elements["parameter[@key='retry']"]
    if new_resource.retry_count.nil? && !retry_el.nil?
      service_el.delete retry_el
    elsif !new_resource.retry_count.nil?
      if retry_el.nil?
        service_el.add_element 'parameter', 'key' => 'retry', 'value' => new_resource.retry_count
      else
        retry_el.attributes['value'] = new_resource.retry_count
      end
    end

    thresholding_enabled_el = service_el.elements["parameter[@key='thresholding-enabled']"]
    if new_resource.thresholding_enabled.nil? && !thresholding_enabled_el.nil?
      service_el.delete thresholding_enabled_el
    elsif !new_resource.thresholding_enabled.nil?
      if thresholding_enabled_el.nil?
        service_el.add_element 'parameter', 'key' => 'thresholding-enabled', 'value' => new_resource.thresholding_enabled
      else
        thresholding_enabled_el.attributes['value'] = new_resource.thresholding_enabled
      end
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  end
end
