# frozen_string_literal: true
include OpennmsXml
include ResourceType
def whyrun_supported?
  true
end

use_inline_resources

action :delete do
  if @current_resource.exists
    converge_by("Deleting #{@new_resource}") do
      delete_xml_group
    end
  else
    Chef::Log.info("#{@new_resource} does not exist - nothing to do.")
  end
end

action :create do
  Chef::Application.fatal!("Missing xml-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  Chef::Application.fatal!("Missing resource-type #{@current_resource.resource_type}.") unless @current_resource.resource_type
  Chef::Application.fatal!("Missing xml-source #{@current_resource.source_url}.") unless @current_resource.source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_xml_group
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsXmlGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.group_name(@new_resource.group_name || @new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.source_url(@new_resource.source_url)
  @current_resource.resource_type(@new_resource.resource_type)
  @current_resource.resource_xpath(@new_resource.resource_xpath) unless @new_resource.resource_xpath.nil?
  @current_resource.key_xpath(@new_resource.key_xpath) unless @new_resource.key_xpath.nil?
  @current_resource.timestamp_xpath(@new_resource.timestamp_xpath) unless @new_resource.timestamp_xpath.nil?
  @current_resource.timestamp_format(@new_resource.timestamp_format) unless @new_resource.timestamp_format.nil?
  @current_resource.objects(@new_resource.objects)

  if collection_exists?(node, @current_resource.collection_name, 'xml')
    @current_resource.collection_exists = true
  end
  if resource_type_exists?(@current_resource.resource_type)
    @current_resource.resource_type_exists = true
  end
  xsr = Chef::Resource::OpennmsXmlSource.new(@current_resource.source_url)
  xsr.url(@current_resource.source_url)
  xsr.collection_name(@current_resource.collection_name)
  @current_resource.source_exists = true if xml_source_exists?(node, xsr)
  @current_resource.exists = true if xml_group_exists?(node, @current_resource)
end

private

def resource_type_exists?(resource_type)
  rt_exists?(node['opennms']['conf']['home'], resource_type) && rt_included?(node['opennms']['conf']['home'], resource_type)
end

def delete_xml_group
  group_name = new_resource.group_name || new_resource.name
  Chef::Log.debug "Creating xml group : '#{group_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  group_el = xml_group_el(doc, new_resource, true)
  Chef::Log.debug("element deleted is #{group_el}")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml")
end

# for now we don't support splitting into include-groups files. But if you use Chef you'll never need to read the file anyway, so who cares? ;)
def create_xml_group
  group_name = new_resource.group_name || new_resource.name
  Chef::Log.debug "Creating xml group : '#{group_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  source_el = doc.elements["/xml-datacollection-config/xml-collection[@name='#{new_resource.collection_name}']/xml-source[@url='#{new_resource.source_url}']"]
  # handle xml-group element
  xg_el = source_el.add_element 'xml-group', 'name' => group_name, 'resource-type' => new_resource.resource_type, 'resource-xpath' => new_resource.resource_xpath
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
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml")
end
