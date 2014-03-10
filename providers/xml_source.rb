def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing xml-collection #{@current_resource.collection_name}.") if !@current_resource.collection_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_xml_source
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlSource.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)

  if collection_exists?(@current_resource.collection_name)
     @current_resource.collection_exists = true
  end
  if source_exists?(@current_resource.collection_name, @current_resource.name)
     @current_resource.collection_exists = true
  end
end


private

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this xml collection exists: '#{ collection_name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']"].nil?
end

def source_exists?(collection_name, name)
  Chef::Log.debug "Checking to see if this xml source exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']/xml-source[@url='#{name}']"].nil?
end

def create_xml_source
  Chef::Log.debug "Creating xml source : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  source_el = doc.elements["/xml-datacollection-config/xml-collection[@name='#{new_resource.collection_name}']"].add_element 'xml-source', {'url' => new_resource.name }
  # handle optional request element and children: params, headers and content
  rq_el = nil
  if !new_resource.request_method.nil?
    rq_el = source_el.add_element 'request', {'method' => new_resource.request_method }
  end
  if !new_resource.request_params.nil?
    if rq_el.nil?
      rq_el = source_el.add_element 'request'
    end
    new_resource.request_params.each do |key, value|
      rq_el.add_element 'parameter', {'name' => key, 'value' => value }
    end
  end
  if !new_resource.request_headers.nil?
    if rq_el.nil?
      rq_el = source_el.add_element 'request'
    end
    new_resource.request_headers.each do |header, value|
      rq_el.add_element 'header', {'name' => header, 'value' => value }
    end
  end
  if !new_resource.request_content.nil?
    if rq_el.nil?
      rq_el = source_el.add_element 'request'
    end
    rq_content_el = rq_el.add_element 'content', {'type' => 'application/x-www-form-urlencoded' }
    rq_content_el.add_text(REXML::CData.new(new_resource.request_content))
  end
  if new_resource.import_groups
    new_resource.import_groups.each { |gf|
      ig_el = source_el.add_element 'import-groups'
      ig_el.add_text(REXML::CData.new("xml-datacollection/#{gf}"))
      cookbook_file gf do
        path "#{node['opennms']['conf']['home']}/etc/xml-datacollection/#{gf}"
        owner "root"
        group "root"
        mode 00644
      end
    }
  #else
  #  xml_groups.each {|name, details|
  #    #TODO: need to validate that selected resource type is present in the collection definition in the main datacollection-config.xml file
  #    xg_el = source_el.add_element 'xml-group', { 'name' => name, 'resource-type' => details['resource_type'], 'resource-xpath' => details['resource_xpath'] }
  #    if details['key_xpath']
  #      xg_el.add_attribute( 'key-xpath' => details['key_xpath'])
  #    end
  #    if details['timestamp_xpath']
  #      xg_el.add_attribute( 'timestamp-xpath' => details['timestamp_xpath'])
  #    end
  #    if details['timestamp_format']
  #      xg_el.add_attribute( 'timestamp-format' => details['timestamp_format'])
  #    end
  #  }
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", "w"){ |file| file.puts(out) }
end
