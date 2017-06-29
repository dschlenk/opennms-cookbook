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
      create_range
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDiscoRange.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.range_begin(@new_resource.range_begin)
  @current_resource.range_end(@new_resource.range_end)
  @current_resource.range_type(@new_resource.range_type)
  @current_resource.location(@new_resource.location)
  @current_resource.foreign_source(@new_resource.foreign_source) unless @new_resource.foreign_source.nil?

  if @current_resource.foreign_source.nil?
    @current_resource.exists = true if range_exists?(@current_resource) # .name, @current_resource.range_begin, @current_resource.range_end, @current_resource.range_type, @current_resource.location, nil)
  elsif range_exists?(@current_resource) # .name, @current_resource.range_begin, @current_resource.range_end, @current_resource.range_type, @current_resource.location, @current_resource.foreign_source)
    @current_resource.exists = true
  elsif foreign_source_exists?(@current_resource.foreign_source, node)
    @current_resource.foreign_source_exists = true
  end
end

private

def range_exists?(current_resource) # _name, range_begin, range_end, range_type, location, foreign_source)
  Chef::Log.debug "Checking to see if this discovery #{current_resource.range_type} range exists: '#{current_resource.range_begin} to #{current_resource.range_end}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml", 'r')
  doc = REXML::Document.new file
  if current_resource.foreign_source.nil?
    if current_resource.location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
      !doc.elements["/discovery-configuration/#{current_resource.range_type}-range/begin[text() ='#{current_resource.range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{current_resource.range_type}-range/end[text() = '#{current_resource.range_end}']"].nil?
    else
      !doc.elements["/discovery-configuration/#{current_resource.range_type}-range/[@location = '#{current_resource.location}']/begin[text() ='#{current_resource.range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{current_resource.range_type}-range/end[text() = '#{current_resource.range_end}']"].nil?
    end
  elsif current_resource.location.nil? || Opennms::Helpers.major(node['opennms']['version']).to_i < 18
    !doc.elements["/discovery-configuration/#{current_resource.range_type}-range[@foreign-source = '#{current_resource.foreign_source}']/begin[text() ='#{current_resource.range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{current_resource.range_type}-range[@foreign-source = '#{current_resource.foreign_source}']/end[text() = '#{current_resource.range_end}']"].nil?
  else
    !doc.elements["/discovery-configuration/#{current_resource.range_type}-range[@location = '#{current_resource.location}' and @foreign-source = '#{current_resource.foreign_source}']/begin[text() ='#{current_resource.range_begin}']"].nil? && !doc.elements["/discovery-configuration/#{current_resource.range_type}-range[@foreign-source = '#{current_resource.foreign_source}']/end[text() = '#{current_resource.range_end}']"].nil?
  end
end

# rubocop:disable Metrics/BlockNesting
def create_range
  Chef::Log.debug "Adding #{new_resource.range_type}-range to discovery: '#{new_resource.range_begin} - #{new_resource.range_end}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  new_el = REXML::Element.new("#{new_resource.range_type}-range")
  new_el.attributes['foreign-source'] = new_resource.foreign_source unless new_resource.foreign_source.nil?
  if Opennms::Helpers.major(node['opennms']['version']).to_i > 17
    new_el.attributes['location'] = new_resource.location unless new_resource.location.nil?
  end
  begin_el = new_el.add_element 'begin'
  begin_el.add_text(new_resource.range_begin)
  end_el = new_el.add_element 'end'
  end_el.add_text(new_resource.range_end)
  unless new_resource.retry_count.nil?
    new_el.attributes['retries'] = new_resource.retry_count
  end
  unless new_resource.timeout.nil?
    new_el.attributes['timeout'] = new_resource.timeout
  end
  last_el = doc.root.elements["/discovery-configuration/#{new_resource.range_type}-range[last()]"]
  if !last_el.nil?
    doc.root.insert_after(last_el, new_el)
  else
    # see if there are any other discovery elements.
    after_el = nil
    before_el = nil
    if new_resource.range_type == 'include'
      after_el = doc.root.elements['/discovery-configuration/specific[last()]']
      if after_el.nil?
        before_el = doc.root.elements['/discovery-configuration/exclude-range[1]']
        if before_el.nil?
          before_el = doc.root.elements['/discovery-configuration/include-url[1]']
        end
      end
      if !after_el.nil?
        doc.root.insert_after(after_el, new_el)
      elsif !before_el.nil?
        doc.root.insert_before(before_el, new_el)
      else
        doc.root.elements['/discovery-configuration'].add_element new_el
      end
    else
      before_el = doc.root.elements['/discovery-configuration/include-url[1]']
      if before_el.nil?
        after_el = doc.root.elements['/discovery-configuration/include-range[last()]']
        if after_el.nil?
          after_el = doc.root.elements['/discovery-configuration/specific[last()]']
        end
      end
      if !before_el.nil?
        doc.root.insert_before(before_el, new_el)
      elsif !after_el.nil?
        doc.root.insert_after(after_el, new_el)
      else
        doc.root.elements['/discovery-configuration'].add_element new_el
      end
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/discovery-configuration.xml")
end
# rubocop:enable Metrics/BlockNesting
