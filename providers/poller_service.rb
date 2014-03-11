def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_poller_service
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSnmpCollectionService.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)

  if service_exists?(@current_resource.package_name, @current_resource.name)
     @current_resource.exists = true
  end
end


private

def service_exists?(package_name, name)
  Chef::Log.debug "Checking to see if this poller service exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/poller-configuration/package[@name='#{package_name}']/service[@name='#{name}']"].nil?
end

def create_poller_service
  Chef::Log.debug "Adding poller service: '#{ new_resource.name }'"
  # Open file
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']"]
  first_downtime_el = doc.elements["/poller-configuration/package[@name='#{new_resource.package_name}']/downtime[1]"]
  Chef::Log.info "First downtime is: #{first_downtime_el}"
  service_el = REXML::Element.new('service')
  service_el.attributes['name'] = new_resource.name
  service_el.attributes['interval'] = new_resource.interval
  service_el.attributes['user-defined'] = new_resource.user_defined
  service_el.attributes['status'] = new_resource.status
  package_el.insert_before(first_downtime_el, service_el)
  if !new_resource.timeout.nil?
    service_el.add_element 'parameter', { 'key' => 'timeout', 'value' => new_resource.timeout }
  end
  if !new_resource.port.nil? 
    service_el.add_element 'parameter', { 'key' => 'port', 'value' => new_resource.port }
  end
  if !new_resource.params.nil?
    new_resource.params.each do |key, value|
      service_el.add_element 'parameter', { 'key' => key, 'value' => value }
    end
  end
  if doc.elements["/poller-configuration/monitor[@service='#{new_resource.name}']"].nil?
    last_monitor_el = doc.elements["/poller-configuration/monitor[last()]"]
    new_mon_el = REXML::Element.new('monitor')
    new_mon_el.attributes['service'] = new_resource.name
    new_mon_el.attributes['class-name'] = new_resource.class_name
    doc.root.insert_after(last_monitor_el, new_mon_el)
  else
    Chef::Log.warn "Existing monitor service exists with possibly conflicting class name. Results not guaranteed. "
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml", "w"){ |file| file.puts(out) }
end
