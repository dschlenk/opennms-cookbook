def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_specific
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsCollectionPackage.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if specific_exists?(@current_resource.name)
     @current_resource.exists = true
  end
end


private

def specific_exists?(name)
  Chef::Log.debug "Checking to see if this collection package exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{name}']"].nil?
end

def create_specific
  Chef::Log.debug "Adding specific IP to discovery: '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close
  new_el = REXML::Element.new("specific")
  new_el.add_text(new_resource.name)
  if !new_resource.retry_count.nil?
    new_el.attributes['retries'] = new_resource.retry_count
  end
  if !new_resource.timeout.nil?
    new_el.attributes['timeout'] = new_resource.timeout
  end
  last_el = doc.root.elements["/discovery-configuration/specific[last()]"]
  if !last_el.nil?
    doc.root.insert_after(last_el, new_el)
  else
    # see if there are any other discovery elements. Specifics should be first.
    before_el = doc.root.elements["/discovery-configuration/include_range[1]"]
    if before_el.nil?
      before_el = doc.root.elements["/discovery-configuration/exclude_range[1]"]
    end
    if before_el.nil?
      before_el = doc.root.elements["/discovery-configuration/include-url[1]"]
    end
    if before_el.nil?
      doc.root.elements["/discovery-configuration"].add_element new_el
    else
      doc.root.insert_before(before_el, new_el)
    end
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", "w"){ |file| file.puts(out) }
end
