def whyrun_supported?
  true
end

use_inline_resources

action :delete do
  if @current_resource.exists
    converge_by("Deleting #{@new_resource}") do
      delete_xml_source
      new_resource.updated_by_last_action(true)
      unless new_resource.import_groups.nil?
        new_resource.import_groups.each do |file|
          file "#{node['opennms']['conf']['home']}/etc/xml-datacollection/#{file}" do
            action :delete
          end
        end
      end
    end
  else
    Chef::Log.info("#{@new_resource} does not exist - nothing to do.")
    new_resource.updated_by_last_action(false)
  end
end

action :create do
  Chef::Application.fatal!("Missing xml-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - updating import-groups files as necessary."
    updated = false
    unless new_resource.import_groups.nil?
      new_resource.import_groups.each do |file|
        f = cookbook_file file do
          path "#{node['opennms']['conf']['home']}/etc/xml-datacollection/#{file}"
          owner 'root'
          group 'root'
          mode 00644
        end
        updated = f.updated_by_last_action? unless updated
      end
    end
    new_resource.updated_by_last_action(updated)
  else
    converge_by("Create #{@new_resource}") do
      create_xml_source
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlSource.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.url(@new_resource.url || @new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.request_method(@new_resource.request_method) unless @new_resource.request_method.nil?
  @current_resource.request_params(@new_resource.request_params) unless @new_resource.request_params.nil?
  @current_resource.request_headers(@new_resource.request_headers) unless @new_resource.request_headers.nil?
  @current_resource.request_content(@new_resource.request_content) unless @new_resource.request_content.nil?
  @current_resource.import_groups(@new_resource.import_groups) unless @new_resource.import_groups.nil?

  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
    if source_exists?(@current_resource)
      @current_resource.exists = true
    end
  end
end

private

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this xml collection exists: '#{collection_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']"].nil?
end

def source_el(doc, resource, delete=false)
  url = resource.url || resource.name
  Chef::Log.debug("url is #{url}")
  xpath = "/xml-datacollection-config/xml-collection[@name='#{resource.collection_name}']/xml-source[@url='#{url}'"
  unless resource.request_method.nil?
    xpath = "#{xpath} and request[@method='#{resource.request_method}']"
  end
  unless resource.request_params.nil?
    resource.request_params.each do |k,v|
      xpath = "#{xpath} and request/parameter[@name='#{k}' and @value='#{v}']"
    end
  end
  unless resource.request_headers.nil?
    resource.request_headers.each do |k,v|
      xpath = "#{xpath} and request/header[@name='#{k}' and @value='#{v}']"
    end
  end
  unless resource.import_groups.nil?
    resource.import_groups.each do |ig|
      xpath = "#{xpath} and import-groups[text()='xml-datacollection/#{ig}']"
    end
  end
  xpath = "#{xpath}]"
  Chef::Log.debug("Checking for XPath '#{xpath}' against document " + doc.to_s)
  source_el = doc.root.elements[xpath]
  Chef::Log.debug("found? #{source_el}")
  doc.root.elements.delete(xpath) if delete
  source_el
end

def source_exists?(resource)
  Chef::Log.debug "Checking to see if this xml source exists: '#{resource.url}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  return !source_el(doc, resource).nil?
end

def delete_xml_source
  url = new_resource.url || new_resource.name
  Chef::Log.debug "Deleting xml_source: '#{url}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  source_el = source_el(doc, new_resource, true)
  Chef::Log.debug("element deleted is a: #{source_el.class.name}")
  out = ''
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.width = 100_000
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'w') { |f| f.puts(out) }
end

def create_xml_source
  url = new_resource.url || new_resource.name
  Chef::Log.debug "Creating xml source : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  source_el = doc.elements["/xml-datacollection-config/xml-collection[@name='#{new_resource.collection_name}']"].add_element 'xml-source', 'url' => url
  # handle optional request element and children: params, headers and content
  rq_el = nil
  unless new_resource.request_method.nil?
    rq_el = source_el.add_element 'request', 'method' => new_resource.request_method
  end
  unless new_resource.request_params.nil?
    rq_el = source_el.add_element 'request' if rq_el.nil?
    new_resource.request_params.each do |key, value|
      rq_el.add_element 'parameter', 'name' => key, 'value' => value
    end
  end
  unless new_resource.request_headers.nil?
    rq_el = source_el.add_element 'request' if rq_el.nil?
    new_resource.request_headers.each do |header, value|
      rq_el.add_element 'header', 'name' => header, 'value' => value
    end
  end
  unless new_resource.request_content.nil?
    rq_el = source_el.add_element 'request' if rq_el.nil?
    rq_content_el = rq_el.add_element 'content', 'type' => 'application/x-www-form-urlencoded'
    rq_content_el.add_text(REXML::CData.new(new_resource.request_content))
  end
  if new_resource.import_groups
    new_resource.import_groups.each do |gf|
      gf = gf.strip
      ig_el = source_el.add_element 'import-groups'
      ig_el.add_text("xml-datacollection/#{gf}")
      cookbook_file gf do
        path "#{node['opennms']['conf']['home']}/etc/xml-datacollection/#{gf}"
        owner 'root'
        group 'root'
        mode 00644
      end
    end
  end

  out = ''
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.width = 100_000
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'w') { |f| f.puts(out) }
end
