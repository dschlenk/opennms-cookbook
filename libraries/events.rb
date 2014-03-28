require 'rexml/document'

module Events
  def event_file_included?(file, node)
    if file =~ /^events\/(.*)$/ 
      file = $1
    end

    ecf = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "r")
    doc = REXML::Document.new ecf
    ecf.close

    !doc.elements["/events/event-file[text() = 'events/#{file}' and not(text()[2])]"].nil?
  end
  def uei_exists?(uei, node)
    exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/eventconf.xml", uei)
    
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/events") do |file|
      next if file !~ /.*\.xml$/
      exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/events/#{file}", uei)
      break if exists
    end
    exists
  end
  def uei_in_file?(file, uei)
    file = ::File.new(file, "r")
    doc = REXML::Document.new file
    file.close
    !doc.elements["/events/event/uei[text() = '#{uei}']"].nil?
  end
  def is_event_file?(file, node)
    fn = "#{node['opennms']['conf']['home']}/etc/#{file}"
    eventfile = false
    if ::File.exists?(fn)
      file = ::File.new(fn, "r")
      doc = REXML::Document.new file
      file.close
      eventfile = !doc.elements["/events"].nil?
    end
    eventfile
  end
  def add_file_to_eventconf(file, position, node)
    Chef::Log.info "file is #{file}"
    if file =~ /^events\/(.*)$/ 
      file = $1
      Chef::Log.info "file is now #{file}"
    end
    f = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
    contents = f.read
    doc = REXML::Document.new(contents, { :respect_whitespace => :all })
    doc.context[:attribute_quote] = :quote
    f.close

    events_el = doc.root.elements["/events"]
    eventconf_el = REXML::Element.new('event-file')
    eventconf_el.add_text(REXML::CData.new("events/#{file}"))
    ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/ncs-component.events.xml']"]
    if position == 'top'
      ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/Translator.default.events.xml']"]
      events_el.insert_after(ref_ef_el, eventconf_el)
    else
      events_el.insert_before(ref_ef_el, eventconf_el)
    end
    out = ""
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    formatter.write(doc, out)
    ::File.open("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "w"){ |f| f.puts(out) }
  end
end
