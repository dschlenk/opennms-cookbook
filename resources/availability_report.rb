include Opennms::XmlHelper
include ::Opennms::Cookbook::AvailabilityReportTemplate

property :report_id, String, name_property: true
property :type, String, equal_to: %w(calendar classic), default: 'calendar'

property :pdf_template, String
property :pdf_template_source, String
property :pdf_template_source_type, String, default: 'cookbook_file', equal_to: %w(cookbook_file template remote_file)
property :pdf_template_source_variables, Hash, default: {}
property :pdf_template_source_properties, Hash, default: {}

property :svg_template, String
property :svg_template_source, String
property :svg_template_source_type, String, default: 'cookbook_file', equal_to: %w(cookbook_file template remote_file)
property :svg_template_source_variables, Hash, default: {}
property :svg_template_source_properties, Hash, default: {}

property :html_template, String
property :html_template_source, String
property :html_template_source_type, String, default: 'cookbook_file', equal_to: %w(cookbook_file template remote_file)
property :html_template_source_variables, Hash, default: {}
property :html_template_source_properties, Hash, default: {}

property :logo, String
property :logo_source, String
property :logo_source_type, String, default: 'cookbook_file', equal_to: %w(cookbook_file template remote_file)
property :logo_source_variables, Hash, default: {}
property :logo_source_properties, Hash, default: {}

property :parameters, Hash, default: {}

default_action :create

load_current_value do
  tpl_resource = availability_template_resource
  config_reports = tpl_resource&.variables[:reports]
  report = config_reports&.find { |r| r[:id] == report_id }

  current_value_does_not_exist! if report.nil?

  type report[:type]
  parameters report[:parameters]
  pdf_template report[:pdf_template]
  svg_template report[:svg_template]
  html_template report[:html_template]
  logo report[:logo]
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::AvailabilityReportTemplate

  def etc_dir
    ::File.join(node['opennms']['home'], 'etc')
  end

  def create_template_file(prefix)
    source = safe_send("#{prefix}_template_source")
    return unless source

    source_type = safe_send("#{prefix}_template_source_type")
    variables = safe_send("#{prefix}_template_source_variables") || {}
    properties = safe_send("#{prefix}_template_source_properties") || {}
    target = ::File.join(etc_dir, safe_send("#{prefix}_template"))

    declare_resource(source_type.to_sym, target) do
      source source
      variables(variables) if source_type == 'template'
      properties.each { |k, v| send(k, v) }
      action :create
    end
  end

  def create_logo_file
    return unless logo

    target = ::File.join(etc_dir, logo)
    declare_resource(logo_source_type.to_sym, target) do
      source logo_source
      variables(logo_source_variables) if logo_source_type == 'template'
      logo_source_properties.each { |k, v| send(k, v) }
      action :create
    end
  end

  def safe_send(prop)
    new_resource.send(prop)
  rescue NoMethodError
    nil
  end
end

action :create do
  converge_if_changed do
    tpl = availability_template_resource
    reports = tpl.variables[:reports] || []

    reports.reject! { |r| r[:id] == report_id }
    reports << {
      id: report_id,
      type: type,
      pdf_template: pdf_template,
      svg_template: svg_template,
      html_template: html_template,
      logo: logo,
      parameters: parameters,
    }

    tpl.variables(reports: reports)

    create_template_file('pdf')
    create_template_file('svg')
    create_template_file('html')
    create_logo_file
  end
end

action :create_if_missing do
  tpl = availability_template_resource
  reports = tpl.variables[:reports] || []
  unless reports.any? { |r| r[:id] == report_id }
    action_create
  end
end

action :delete do
  tpl = availability_template_resource
  reports = tpl.variables[:reports] || []

  if reports.any? { |r| r[:id] == report_id }
    reports.reject! { |r| r[:id] == report_id }
    tpl.variables(reports: reports)
  end
end
