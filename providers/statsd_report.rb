# frozen_string_literal: true
include Statsd

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing statsd package #{@current_resource.package_name}.") unless @current_resource.package_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_report
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsStatsdReport.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.report_name(@new_resource.report_name) unless @new_resource.report_name.nil?
  @current_resource.package_name(@new_resource.package_name)

  if package_exists?(@current_resource.package_name, node)
    @current_resource.package_exists = true
    if report_exists?(@current_resource.name, @current_resource.report_name, @current_resource.package_name, node)
      @current_resource.exists = true
    end
  end
end

private

def create_report
  Chef::Log.debug "Creating packageReport : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/statsd-configuration.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  name = new_resource.report_name.nil? ? new_resource.name : new_resource.report_name
  package_el = doc.elements["/statistics-daemon-configuration/package[@name='#{new_resource.package_name}']"]
  report_el = package_el.add_element 'packageReport', 'name' => name, 'description' => new_resource.description, 'schedule' => new_resource.schedule, 'retainInterval' => new_resource.retain_interval, 'status' => new_resource.status
  unless new_resource.parameters.nil?
    new_resource.parameters.each do |key, value|
      report_el.add_element 'parameter', 'key' => key, 'value' => value
    end
  end

  # Note that there is the chance here for unexpected results - if a report
  # with the same name exists in two packages and you're hoping to use
  # different class names for each, you are out of luck. The first defined
  # will win.
  report_class_el = doc.elements["/statistics-daemon-configuration/report[@name='#{name}']"]
  if report_class_el.nil?
    doc.root.add_element 'report', 'name' => name, 'class-name' => new_resource.class_name
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/statsd-configuration.xml")
end
