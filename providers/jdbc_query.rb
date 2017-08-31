# frozen_string_literal: true
include ResourceType
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing jdbc-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  Chef::Application.fatal!("Missing resourceType #{@current_resource.resource_type}.") unless @current_resource.resource_type_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_jdbc_query
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJdbcQuery.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.resource_type(@new_resource.resource_type)

  if query_exists?(@current_resource.name, @current_resource.collection_name)
    @current_resource.exists = true
  end
  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
  end
  if resource_type_exists?(@current_resource.resource_type)
    @current_resource.resource_type_exists = true
  end
end

private

def resource_type_exists?(resource_type)
  rt_exists?(node['opennms']['conf']['home'], resource_type) && rt_included?(node['opennms']['conf']['home'], resource_type)
end

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this jdbc collection exists: '#{collection_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jdbc-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{collection_name}']"].nil?
end

def query_exists?(name, collection_name)
  Chef::Log.debug "Checking to see if this jdbc query exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jdbc-datacollection-config.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{collection_name}']/queries/query[@name='#{name}']"].nil?
end

def create_jdbc_query
  Chef::Log.debug "Creating jdbc query : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/jdbc-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  queries_el = doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{new_resource.collection_name}']/queries"]
  unless queries_el.nil?
    query_el = queries_el.add_element 'query', 'name' => new_resource.name, 'ifType' => new_resource.if_type, 'recheckInterval' => new_resource.recheck_interval, 'resourceType' => new_resource.resource_type
    if new_resource.instance_column
      query_el.add_attribute('instance-column', new_resource.instance_column)
    end
    if new_resource.query_string
      statement_el = query_el.add_element 'statement'
      qs_el = statement_el.add_element 'queryString'
      qs_el.add_text(REXML::CData.new(new_resource.query_string))
    end
    if new_resource.columns
      columns_el = query_el.add_element 'columns'
      new_resource.columns.each do |name, details|
        column_el = columns_el.add_element 'column', 'name' => name, 'type' => details['type'], 'alias' => details['alias']
        if details['data_source_name']
          column_el.add_attribute('data-source-name', details['data_source_name'])
        end
      end
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/jdbc-datacollection-config.xml")
  end
end
