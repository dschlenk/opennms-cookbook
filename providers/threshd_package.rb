# frozen_string_literal: true
include Threshold
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    if @current_resource.changed
      converge_by("Update #{new_resource}") do
        update_threshd_package
      end
    else
      Chef::Log.info "#{@new_resource} already exists - nothing to do."
    end
  else
    converge_by("Create #{@new_resource}") do
      create_threshd_package
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_threshd_package
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{new_resource}") do
      delete_threshd_package
    end
  else
    Chef::Log.info("#{new_resource} doesn't exist - nothing to do.")
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_threshd_package, node).new(@new_resource.package_name || @new_resource.name)
  @current_resource.filter(@new_resource.filter)
  @current_resource.specifics(@new_resource.specifics)
  @current_resource.include_ranges(@new_resource.include_ranges)
  @current_resource.exclude_ranges(@new_resource.exclude_ranges)
  @current_resource.include_urls(@new_resource.include_urls)
  @current_resource.services(@new_resource.services)
  @current_resource.outage_calendars(@new_resource.outage_calendars)

  @current_resource.exists = package_exists?(@current_resource.name, node)
  if @current_resource.exists
    @current_resource.changed = package_changed?(@current_resource, node)
  end
end

private

def delete_threshd_package
  name = new_resource.package_name || new_resource.name
  Chef::Log.debug "Deleting threshd package: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  doc.delete_element("/threshd-configuration/package[@name='#{name}']")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
end

def update_threshd_package
  name = new_resource.package_name || new_resource.name
  Chef::Log.debug "Updating threshd package: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  package_el = doc.elements["/threshd-configuration/package[@name='#{name}']"]
  filter_el = package_el.elements['filter']
  filter_el.text = REXML::CData.new(new_resource.filter)
  unless new_resource.specifics.nil?
    package_el.elements.delete_all 'specific'
    new_resource.specifics.each do |specific|
      specific_el = package_el.add_element 'specific'
      specific_el.add_text specific
    end
  end
  unless new_resource.include_ranges.nil?
    package_el.elements.delete_all 'include-range'
    new_resource.include_ranges.each do |range|
      package_el.add_element 'include-range', 'begin' => range['begin'], 'end' => range['end']
    end
  end
  unless new_resource.exclude_ranges.nil?
    package_el.elements.delete_all 'exclude-range'
    new_resource.exclude_ranges.each do |range|
      package_el.add_element 'exclude-range', 'begin' => range['begin'], 'end' => range['end']
    end
  end
  unless new_resource.include_urls.nil?
    package_el.elements.delete_all 'include-url'
    new_resource.include_urls.each do |url|
      include_url_el = package_el.add_element 'include-url'
      include_url_el.add_text url
    end
  end
  unless new_resource.services.nil?
    package_el.elements.delete_all 'service'
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
    package_el.elements.delete_all 'outage-calendar'
    new_resource.outage_calendars.each do |calendar|
      cal_el = package_el.add_element 'outage-calendar'
      cal_el.add_text calendar
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
end

def create_threshd_package
  name = new_resource.package_name || new_resource.name
  Chef::Log.debug "Adding threshd package: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/threshd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  package_el = REXML::Element.new 'package'
  package_el.attributes['name'] = name
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
