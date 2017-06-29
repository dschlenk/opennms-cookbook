# frozen_string_literal: true
include OpennmsXml
def whyrun_supported?
  true
end

use_inline_resources

action :delete do
  if @current_resource.exists
    converge_by("Deleting #{@new_resource}") do
      delete_xml_source
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
  end
end

action :create do
  Chef::Application.fatal!("Missing xml-collection #{@current_resource.collection_name}.") unless @current_resource.collection_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - updating import-groups files as necessary."
    unless new_resource.import_groups.nil?
      new_resource.import_groups.each do |file|
        f = cookbook_file file do
          path "#{node['opennms']['conf']['home']}/etc/xml-datacollection/#{file}"
          owner 'root'
          group 'root'
          mode 00644
        end
        converge_by("Update #{@new_resource}") if f.updated_by_last_action?
      end
    end
  else
    converge_by("Create #{@new_resource}") do
      create_xml_source
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

  if collection_exists?(node, @current_resource.collection_name, 'xml')
    @current_resource.collection_exists = true
    if xml_source_exists?(node, @current_resource)
      @current_resource.exists = true
    end
  end
end

private

def delete_xml_source
  url = new_resource.url || new_resource.name
  Chef::Log.debug "Deleting xml_source: '#{url}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  source_el = source_el(doc, new_resource, true)
  Chef::Log.debug("element deleted is a: #{source_el.class.name}")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml")
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

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/xml-datacollection-config.xml")
end
