# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @new_resource.name =~ /^file:(.*$)/
    if @new_resource.file_name.nil?
      Chef::Application.fatal!("Missing file_name attribute when a file was specified in the include-url: #{@new_resource.name}.")
    end
  end
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  elsif !@current_resource.foreign_source.nil? && !@current_resource.foreign_source_exists
    Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source}.")
  else
    converge_by("Create #{@new_resource}") do
      create_url
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDiscoUrl.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.location(@new_resource.location) unless @new_resource.location.nil?
  @current_resource.foreign_source(@new_resource.foreign_source) unless @new_resource.foreign_source.nil?

  if @current_resource.foreign_source.nil?
    if url_exists?(@current_resource.name, @current_resource.location, nil)
      @current_resource.exists = true
    end
  elsif url_exists?(@current_resource.name, @current_resource.location, @current_resource.foreign_source)
    @current_resource.exists = true
  elsif foreign_source_exists?(@current_resource.foreign_source, node)
    @current_resource.foreign_source_exists = true
  end
end

private

def url_exists?(name, location, foreign_source)
  Chef::Log.debug "Checking to see if this include-url exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", 'r')
  doc = REXML::Document.new file
  if foreign_source.nil?
    if location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
      !doc.elements["/discovery-configuration/include-url[text() ='#{name}']"].nil?
    else
      !doc.elements["/discovery-configuration/include-url[@location = '#{location}' and text() ='#{name}']"].nil?
    end
  elsif location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
    !doc.elements["/discovery-configuration/include-url[text() ='#{name}' and @foreign-source = '#{foreign_source}']"].nil?
  else
    !doc.elements["/discovery-configuration/include-url[@location = '#{location}' and text() ='#{name}' and @foreign-source = '#{foreign_source}']"].nil?
  end
end

def create_url
  if new_resource.name =~ /^file:(.*$)/
    Chef::Log.debug "Placing file in: '#{Regexp.last_match(1)}'"
    cookbook_file new_resource.file_name do
      path Regexp.last_match(1)
      owner 'root'
      group 'root'
      mode 00644
    end
  end
  Chef::Log.debug "Adding include-url to discovery: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  new_el = REXML::Element.new('include-url')
  if Opennms::Helpers.major(node['opennms']['version']).to_i > 17
    new_el.attributes['location'] = new_resource.location unless new_resource.location.nil?
  end
  new_el.attributes['foreign-source'] = new_resource.foreign_source unless new_resource.foreign_source.nil?
  new_el.add_text(new_resource.name)
  unless new_resource.retry_count.nil?
    new_el.attributes['retries'] = new_resource.retry_count
  end
  unless new_resource.timeout.nil?
    new_el.attributes['timeout'] = new_resource.timeout
  end
  doc.root.elements['/discovery-configuration'].add_element new_el
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
end
