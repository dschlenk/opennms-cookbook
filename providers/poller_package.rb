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
      create_poller_package
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsPollerPackage.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if package_exists?(@current_resource.name)
end

private

def package_exists?(name)
  Chef::Log.debug "Checking to see if this poller package exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/poller-configuration/package[@name='#{name}']"].nil?
end

def create_poller_package
  Chef::Log.debug "Adding poller package: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  last_pkg_el = doc.root.elements['/poller-configuration/package[last()]']
  doc.root.insert_after(last_pkg_el, REXML::Element.new('package'))
  package_el = doc.root.elements['/poller-configuration/package[last()]']
  package_el.attributes['name'] = new_resource.name
  filter_el = package_el.add_element('filter')
  filter_el.add_text(REXML::CData.new(new_resource.filter))
  unless new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      specific_el = package_el.add_element('specific')
      specific_el.add_text(specific)
    end
  end
  unless new_resource.include_ranges.nil?
    new_resource.include_ranges.each do |range_begin, range_end|
      include_range_el = package_el.add_element('include-range')
      include_range_el.add_attribute('begin', range_begin)
      include_range_el.add_attribute('end', range_end)
    end
  end
  unless new_resource.exclude_ranges.nil?
    new_resource.exclude_ranges.each do |range_begin, range_end|
      exclude_range_el = package_el.add_element('exclude-range')
      exclude_range_el.add_attribute('begin', range_begin)
      exclude_range_el.add_attribute('end', range_end)
    end
  end
  unless new_resource.include_urls.nil?
    new_resource.include_urls.each do |include_url|
      include_url_el = package_el.add_element('include-url')
      include_url_el.add_text(include_url)
    end
  end
  rrd_el = package_el.add_element 'rrd', 'step' => new_resource.rrd_step
  new_resource.rras.each do |rra|
    rra_el = rrd_el.add_element 'rra'
    rra_el.add_text(rra)
  end
  unless new_resource.outage_calendars.nil?
    new_resource.outage_calendars.each do |outage_calendar|
      outage_el = package_el.add_element 'outage_calendar'
      outage_el.add_text(outage_calendar)
    end
  end
  unless new_resource.downtimes.nil?
    new_resource.downtimes.each do |start, details|
      downtime_el = package_el.add_element 'downtime', 'begin' => start
      unless details['interval'].nil?
        downtime_el.add_attribute('interval', details['interval'])
      end
      downtime_el.add_attribute('end', details['end']) unless details['end'].nil?
      unless details['delete'].nil?
        downtime_el.add_attribute('delete', details['delete'])
      end
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poller-configuration.xml")
end
