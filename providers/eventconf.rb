def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_eventconf
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsEventconf.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if eventconf_exists?(@current_resource.name)
     @current_resource.exists = true
  end
end


private

def eventconf_exists?(name)
  Chef::Log.debug "Checking to see if this eventconf file exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/events/event-file[text() = 'events/#{name}' and not(text()[2])]"].nil?
end

def create_eventconf
  Chef::Log.debug "Placing new eventconf file: '#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}'"
  cookbook_file new_resource.name do
    path "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.name}"
    owner "root"
    group "root"
    mode 00644
  end

  Chef::Log.debug "Adding eventconf: '#{ new_resource.name }' to main eventconf.xml"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close
  
  events_el = doc.root.elements["/events"]
  eventconf_el = REXML::Element.new('event-file')
  eventconf_el.add_text(REXML::CData.new("events/#{new_resource.name}"))
  last_pkg_el = doc.root.elements["/events/event-file[text() = 'events/ncs-component.events.xml']"]
  if new_resource.position == 'top'
    last_pkg_el = doc.root.elements["/events/event-file[text() = 'events/Translator.default.events.xml']"]
    events_el.insert_after(last_pkg_el, eventconf_el)
  else
    events_el.insert_before(last_pkg_el, eventconf_el)
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "w"){ |file| file.puts(out) }
end
