# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_threshd_package
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsThreshdPackage.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if package_exists?(@current_resource.name)
end

private

def package_exists?(name)
  Chef::Log.debug "Checking to see if this threshd package exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/threshd-configuration/package[@name='#{name}']"].nil?
end

def create_threshd_package
  Chef::Log.debug "Adding threshd package: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = REXML::Element.new 'package'
  package_el.attributes['name'] = new_resource.name
  filter_el = package_el.add_element 'filter'
  filter_el.add_text(REXML::CData.new(new_resource.filter))
  unless new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      specific_el = package_el.add_element 'specific'
      specific_el.add_text specific
    end
  end
  unless new_resource.include_ranges.nil?
    new_resource.include_ranges.each do |range|
      package_el.add_element 'include-range', 'begin' => range['begin'], 'end' => range['end']
    end
    unless new_resource.exclude_ranges.nil?
      new_resource.exclude_ranges.each do |range|
        package_el.add_element 'exclude-range', 'begin' => range['begin'], 'end' => range['end']
      end
    end
  end
  unless new_resource.include_urls.nil?
    new_resource.include_urls.each do |url|
      include_url_el = package_el.add_element 'include-url'
      include_url_el.add_text url
    end
  end
  unless new_resource.services.nil?
    new_resource.services.each do |service|
      service_el = package_el.add_element 'service', 'name' => service['name'], 'interval' => service['interval']
      service_el.attributes['user-defined'] = service['user_defined'] if service.key? 'user_defined'
      service_el.attributes['status'] = service['status'] if service.key? 'status'
      next unless service.key? 'params'
      service['params'].each do |key, value|
        service_el.add_element 'parameter', 'key' => key, 'value' => value
      end
    end
  end
  unless new_resource.outage_calendars.nil?
    new_resource.outage_calendars.each do |calendar|
      cal_el = package_el.add_element 'outage-calendar'
      cal_el.add_text calendar
    end
  end
  last_package_el = doc.root.elements['/threshd-configuration/package[last()]']
  if last_package_el.nil?
    doc.root.add_element package_el
  else
    doc.root.insert_after(last_package_el, package_el)
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
end
