def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_autoack_alarm
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsNotifdAutoackAlarm.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if autoack_alarm_exists?(@current_resource.name)
    @current_resource.exists = true
  end
end

private

def autoack_alarm_exists?(name)
  Chef::Log.debug "Checking to see if this autoack_alarm exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml", "r")
  doc = REXML::Document.new file
  file.close
  !doc.elements["/notifd-configuration/auto-acknowledge-alarm[@resolution-prefix = '#{name}']"].nil?
end

def create_autoack_alarm
  Chef::Log.debug "Creating autoack_alarm : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  last_autoack_alarm_el = doc.root.elements["/notifd-configuration/auto-acknowledge-alarm[last()]"]
  autoack_el = REXML::Element.new 'auto-acknowledge-alarm'
  autoack_el.attributes['resolution-prefix'] = new_resource.name
  autoack_el.attributes['notify'] = new_resource.notify
  new_resource.uei.each do |uei|
    match_el = autoack_el.add_element 'uei'
    match_el.add_text uei
  end
  if last_autoack_alarm_el.nil?
    first_autoack_el = doc.root.elements["/notifd-configuration/auto-acknowledge[1]"]
    if !first_autoack_el.nil?
      doc.root.insert_before(first_autoack_el, autoack_el)
    else
      first_queue_el = doc.root.elements["/notifd-configuration/queue[1]"]
      doc.root.insert_before(first_queue_el, autoack_el)
    end
  else
    doc.root.insert_after(last_autoack_alarm_el, autoack_el)
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml", "w"){ |file| file.puts(out) }
end
