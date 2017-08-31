# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  elsif !@current_resource.foreign_source.nil? && !@current_resource.foreign_source_exists
    Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source}.")
  else
    converge_by("Create #{@new_resource}") do
      create_specific
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDiscoSpecific.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.location(@new_resource.location) unless @new_resource.location.nil?
  @current_resource.foreign_source(@new_resource.foreign_source) unless @new_resource.foreign_source.nil?

  if @current_resource.foreign_source.nil?
    if specific_exists?(@current_resource.name, @current_resource.location, nil)
      @current_resource.exists = true
    end
  elsif specific_exists?(@current_resource.name, @current_resource.location, @current_resource.foreign_source)
    @current_resource.exists = true
  elsif foreign_source_exists?(@current_resource.foreign_source, node)
    @current_resource.foreign_source_exists = true
  end
end

private

def specific_exists?(name, location, foreign_source)
  Chef::Log.debug "Checking to see if this specific IP exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", 'r')
  doc = REXML::Document.new file
  if foreign_source.nil?
    if location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
      !doc.elements["/discovery-configuration/specific[text() ='#{name}]"].nil?
    else
      !doc.elements["/discovery-configuration/specific[@location = '#{location}' and text() = '#{name}]"].nil?
    end
  elsif location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
    !doc.elements["/discovery-configuration/specific[text() ='#{name} and @foreign-source = '#{foreign_source}']"].nil?
  else
    !doc.elements["/discovery-configuration/specific[@location = '#{location}' and text() = '#{name} and @foreign-source = '#{foreign_source}']"].nil?
  end
end

def create_specific
  Chef::Log.debug "Adding specific IP to discovery: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  new_el = REXML::Element.new('specific')
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
  last_el = doc.root.elements['/discovery-configuration/specific[last()]']
  if !last_el.nil?
    doc.root.insert_after(last_el, new_el)
  else
    # see if there are any other discovery elements. Specifics should be first.
    before_el = doc.root.elements['/discovery-configuration/include_range[1]']
    if before_el.nil?
      before_el = doc.root.elements['/discovery-configuration/exclude_range[1]']
    end
    if before_el.nil?
      before_el = doc.root.elements['/discovery-configuration/include-url[1]']
    end
    if before_el.nil?
      doc.root.elements['/discovery-configuration'].add_element new_el
    else
      doc.root.insert_before(before_el, new_el)
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
end
