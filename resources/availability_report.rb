include Opennms::XmlHelper
include Opennms::Cookbook::ConfigHelpers::AvailabilityReportTemplate

property :report_id, String, name_property: true
property :type, String, equal_to: %w(calendar classic), default: 'calendar'

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
  unless ::File.exist?(file_path)
    current_value_does_not_exist!
    next
  end

  file = ::File.read(file_path)
  doc = REXML::Document.new(file)
  report = REXML::XPath.first(doc, "//report[@id='#{desired.report_id}']")
  if report.nil?
    current_value_does_not_exist!
    next
  end

  type report.attributes['type']

  parameters_hash = {
    'string_parms' => [],
    'date_parms' => [],
    'int_parms' => [],
  }

  param_elem = report.elements['parameters']
  if param_elem
    param_elem.elements.each('string-parm') do |el|
      parameters_hash['string_parms'] << el.attributes.to_h.transform_keys { |k| k.tr('-', '_') }
    end

    param_elem.elements.each('date-parm') do |el|
      dp = {
        'name' => el.attributes['name'],
        'display_name' => el.attributes['display-name'],
        'use_absolute_date' => el.attributes['use-absolute-date'],
        'default_interval' => el.attributes['default-interval'],
        'default_count' => el.attributes['default-count'],
      }
      if (dt = el.elements['default-time'])
        dp['default_time'] = {
          'hour' => dt.attributes['hour'],
          'minute' => dt.attributes['minute'],
        }
      end
      parameters_hash['date_parms'] << dp
    end

    param_elem.elements.each('int-parm') do |el|
      parameters_hash['int_parms'] << el.attributes.to_h.transform_keys { |k| k.tr('-', '_') }
    end
  end

  parameters parameters_hash
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::ConfigHelpers::AvailabilityReportTemplate

  def config_file
    ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
  end

  def load_xml_document
    require 'rexml/document'
    file = ::File.read(config_file)
    REXML::Document.new(file)
  end

  def save_xml_document(doc)
    ::File.open(config_file, 'w') do |f|
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      formatter.write(doc, f)
    end
  end

  def find_or_create_report_element(doc)
    doc.root ||= REXML::Element.new('reports-configuration')
    reports_el = doc.root.elements['reports'] || doc.root.add_element('reports')
    report_elem = REXML::XPath.first(doc, "//report[@id='#{new_resource.report_id}']")
    unless report_elem
      report_elem = REXML::Element.new('report')
      report_elem.add_attribute('id', new_resource.report_id)
      reports_el.add_element(report_elem)
    end
    report_elem
  end

  def update_report_element(report_elem)
    report_elem.attributes['type'] = new_resource.type
    report_elem.elements.delete_all('parameters')
    build_parameters_xml(report_elem)
  end

  def validate_or_create_file(prefix)
    template = new_resource.send("#{prefix}_template")
    source = new_resource.send("#{prefix}_template_source")
    source_type = new_resource.send("#{prefix}_template_source_type")
    variables = new_resource.send("#{prefix}_template_source_variables")
    props = new_resource.send("#{prefix}_template_source_properties")

    return if template.nil?

    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', template)

    if source
      send(source_type, target_path) do
        source source
        variables variables if source_type == 'template'
        props.each { |k, v| send(k, v) }
      end
    elsif !::File.exist?(target_path)
      raise "#{prefix}_template file '#{template}' not found in #{target_path} and no source provided"
    end
  end

  def build_parameters_xml(report_elem)
    return unless new_resource.parameters
    params = new_resource.parameters
    return if params.empty?

    param_elem = REXML::Element.new('parameters')

    Array(params['string_parms']).each do |sp|
      string_elem = REXML::Element.new('string-parm')
      sp.each { |k, v| string_elem.add_attribute(k.to_s.tr('_', '-'), v.to_s) }
      param_elem.add_element(string_elem)
    end

    Array(params['date_parms']).each do |dp|
      date_elem = REXML::Element.new('date-parm')
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
      int_elem = REXML::Element.new('int-parm')
      ip.each { |k, v| int_elem.add_attribute(k.to_s.tr('_', '-'), v.to_s) }
      param_elem.add_element(int_elem)
    end

    report_elem.add_element(param_elem)
  end
end

action :create do
  converge_if_changed do
    raise "File not found: #{config_file}" unless ::File.exist?(config_file)

    doc = load_xml_document
    report_elem = find_or_create_report_element(doc)
    update_report_element(report_elem)
    save_xml_document(doc)
  end

  %w(pdf svg html).each do |prefix|
    validate_or_create_file(prefix)
  end

  if new_resource.logo
    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', new_resource.logo)
    if new_resource.logo_source
      send(new_resource.logo_source_type, target_path) do
        source new_resource.logo_source
        variables new_resource.logo_source_variables if new_resource.logo_source_type == 'template'
        new_resource.logo_source_properties.each { |k, v| send(k, v) }
      end
    elsif !::File.exist?(target_path)
      raise "logo file '#{new_resource.logo}' not found in #{target_path} and no source provided"
    end
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

  ::File.open(file_path, 'w') do |f|
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, f)
  end
end
