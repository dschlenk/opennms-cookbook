include Opennms::XmlHelper
include Opennms::Cookbook::ConfigHelpers::AvailabilityReportTemplate

provides :opennms_availability_report

property :report_id, String, name_property: true
property :type, String, required: true, equal_to: %w(calendar classic)

property :pdf_template, String
property :pdf_template_source, String
property :pdf_template_source_type, String, default: 'cookbook_file'
property :pdf_template_source_variables, Hash, default: {}
property :pdf_template_source_properties, Hash, default: {}

property :svg_template, String
property :svg_template_source, String
property :svg_template_source_type, String, default: 'cookbook_file'
property :svg_template_source_variables, Hash, default: {}
property :svg_template_source_properties, Hash, default: {}

property :html_template, String
property :html_template_source, String
property :html_template_source_type, String, default: 'cookbook_file'
property :html_template_source_variables, Hash, default: {}
property :html_template_source_properties, Hash, default: {}

property :logo, String
property :logo_source, String
property :logo_source_type, String, default: 'cookbook_file'
property :logo_source_variables, Hash, default: {}
property :logo_source_properties, Hash, default: {}

property :parameters, Hash, default: {}

default_action :create

load_current_value do |desired|
  require 'rexml/document'
  file_path = ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
  if ::File.exist?(file_path)
    file = ::File.read(file_path)
    doc = REXML::Document.new(file)
    report = REXML::XPath.first(doc, "//report[@id='#{desired.report_id}']")
    current_value_does_not_exist! if report.nil?
    type report.attributes['type']
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::ConfigHelpers::AvailabilityReportTemplate

  def config_file
    ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
  end

  def validate_or_create_file(type)
    template = new_resource.send("#{type}_template")
    source = new_resource.send("#{type}_template_source")
    source_type = new_resource.send("#{type}_template_source_type")
    variables = new_resource.send("#{type}_template_source_variables")
    props = new_resource.send("#{type}_template_source_properties")

    return if template.nil?

    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', template)

    if source
      send(source_type, target_path) do
        source source
        variables variables if source_type == 'template'
        props.each { |k, v| send(k, v) }
      end
    elsif !::File.exist?(target_path)
      raise "#{type}_template file '#{template}' not found in #{target_path} and no source provided"
    end
  end

  def build_parameters_xml(report_elem)
    return unless new_resource.parameters
    params = new_resource.parameters
    return if params.empty?

    param_elem = REXML::Element.new('parameters')

    Array(params['string_parms']).each do |sp|
      string_elem = REXML::Element.new('string-parameter')
      sp.each { |k, v| string_elem.add_attribute(k.to_s.tr('_', '-'), v.to_s) }
      param_elem.add_element(string_elem)
    end

    Array(params['date_parms']).each do |dp|
      date_elem = REXML::Element.new('date-parameter')
      date_elem.add_attribute('name', dp['name'])
      date_elem.add_attribute('display-name', dp['display_name'])
      date_elem.add_attribute('use-absolute-date', dp['use_absolute_date'].to_s)
      date_elem.add_attribute('default-interval', dp['default_interval'])
      date_elem.add_attribute('default-count', dp['default_count'].to_s)

      if dp['default_time']
        time_elem = REXML::Element.new('default-time')
        time_elem.add_attribute('hour', dp['default_time']['hour'].to_s)
        time_elem.add_attribute('minute', dp['default_time']['minute'].to_s)
        date_elem.add_element(time_elem)
      end

      param_elem.add_element(date_elem)
    end

    Array(params['int_parms']).each do |ip|
      int_elem = REXML::Element.new('int-parameter')
      ip.each { |k, v| int_elem.add_attribute(k.to_s.tr('_', '-'), v.to_s) }
      param_elem.add_element(int_elem)
    end

    report_elem.add_element(param_elem)
  end
end

action :create do
  converge_if_changed do
    require 'rexml/document'

    file_path = config_file
    raise "File not found: #{file_path}" unless ::File.exist?(file_path)

    file = ::File.read(file_path)
    doc = REXML::Document.new(file)

    doc.elements.each("//report[@id='#{new_resource.report_id}']") { |el| el.parent.delete(el) }

    report_elem = REXML::Element.new('report')
    report_elem.add_attribute('id', new_resource.report_id)
    report_elem.add_attribute('type', new_resource.type)

    build_parameters_xml(report_elem)

    doc.root ||= REXML::Element.new('reports-configuration')
    reports_el = doc.root.elements['reports'] || doc.root.add_element('reports')
    reports_el.add_element(report_elem)

    File.open(file_path, 'w') do |f|
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      formatter.write(doc, f)
    end
  end

  %w(pdf svg html logo).each do |type|
    validate_or_create_file(type)
  end
end

action :create_if_missing do
  require 'rexml/document'

  file_path = config_file
  found = false
  if ::File.exist?(file_path)
    file = ::File.read(file_path)
    doc = REXML::Document.new(file)
    found = !REXML::XPath.first(doc, "//report[@id='#{new_resource.report_id}']").nil?
  end
  run_action(:create) unless found
end

action :delete do
  require 'rexml/document'

  file_path = config_file
  raise "File not found: #{file_path}" unless ::File.exist?(file_path)

  file = ::File.read(file_path)
  doc = REXML::Document.new(file)

  node = REXML::XPath.first(doc, "//report[@id='#{new_resource.report_id}']")
  node.parent.delete(node) if node

  File.open(file_path, 'w') do |f|
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, f)
  end
end
