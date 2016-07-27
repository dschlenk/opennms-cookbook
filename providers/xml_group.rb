include ResourceType
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing xml-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  Chef::Application.fatal!("Missing resource-type #{@current_resource.resource_type}.") unless @current_resource.resource_type
  Chef::Application.fatal!("Missing xml-source #{@current_resource.source_url}.") unless @current_resource.source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_xml_group
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.source_url(@new_resource.source_url)
  @current_resource.resource_type(@new_resource.resource_type)

  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
  end
  if resource_type_exists?(@current_resource.resource_type)
    @current_resource.resource_type_exists = true
  end
  if source_exists?(@current_resource.collection_name, @current_resource.source_url)
    @current_resource.source_exists = true
  end
  if group_exists?(@current_resource.collection_name, @current_resource.source_url, @current_resource.name)
    @current_resource.exists = true
  end
end

private

def resource_type_exists?(resource_type)
  rt_exists?(node['opennms']['conf']['home'], resource_type) && rt_included?(node['opennms']['conf']['home'], resource_type)
end

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this xml collection exists: '#{collection_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']"].nil?
end

def source_exists?(collection_name, url)
  Chef::Log.debug "Checking to see if this xml source exists: '#{url}'"
  return false unless collection_exists?(collection_name)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']/xml-source[@url='#{url}']"].nil?
end

def group_exists?(collection_name, url, name)
  exists = false
  Chef::Log.debug "Checking to see if this xml group exists: '#{name}'"
  return false unless source_exists?(collection_name, url)
  # look in main file first
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  return true unless doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']/xml-source[@url='#{url}']/xml-group[@name='#{name}']"].nil?
  # look in included files
  import_els = doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection_name}']/xml-source[@url='#{url}']/import-groups"]
  # Dir.foreach("#{node['opennms']['conf']['home']}/etc/xml-datacollection") do |include_file|
  unless import_els.nil?
    import_els.each do |import_cdata|
      include_file = import_cdata.to_s
      # next if include_file !~ /.*\.xml$/
      # we're assuming that the include file follows every example ever and is relative to $onms_home/etc/
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{include_file}", 'r')
      doc = REXML::Document.new file
      file.close
      exists = !doc.elements["/xml-groups/xml-group[@name='#{name}']"].nil?
      break if exists
    end
  end
  exists
end

# for now we don't support splitting into include-groups files. But if you use Chef you'll never need to read the file anyway, so who cares? ;)
def create_xml_group
  Chef::Log.debug "Creating xml group : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  source_el = doc.elements["/xml-datacollection-config/xml-collection[@name='#{new_resource.collection_name}']/xml-source[@url='#{new_resource.source_url}']"]
  # handle xml-group element
  xg_el = source_el.add_element 'xml-group', 'name' => new_resource.name, 'resource-type' => new_resource.resource_type, 'resource-xpath' => new_resource.resource_xpath
  Chef::Log.info "key_xpath: #{new_resource.key_xpath}"
  unless new_resource.key_xpath.nil?
    Chef::Log.info 'key_xpath defined!'
    xg_el.attributes['key-xpath'] = new_resource.key_xpath
  end
  unless new_resource.timestamp_xpath.nil?
    xg_el.attributes['timestamp-xpath'] = new_resource.timestamp_xpath
  end
  unless new_resource.timestamp_format.nil?
    xg_el.attributes['timestamp-format'] = new_resource.timestamp_format
  end
  # handle xml-object elements
  unless new_resource.objects.nil?
    new_resource.objects.each do |name, details|
      xg_el.add_element 'xml-object', 'name' => name, 'type' => details['type'], 'xpath' => details['xpath']
    end
  end
  out = ''
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.width = 100_000
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'w') { |file| file.puts(out) }
end
