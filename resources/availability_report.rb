include Opennms::XmlHelper
include Opennms::Cookbook::AvailabilityReportHeler::AvailabilityReportTemplate

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
property :onms_home, String, default: '/opt/opennms'

default_action :create

load_current_value do |new_resource|
  config = if !availability_template_resource.nil?
             availability_template_resource.variables(:config)
           else
             ro_availability_template_resource_init
             ro_availability_template_resource.variables(:config)
           end
  report = config.find_by_id(new_resource.report_id)
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
  include Opennms::Cookbook::AvailabilityReportHelper::AvailabilityReportTemplate
end

action :create do
  # TODO: create cookbook_file/template/remote_file resource for each of pdf_template, svg_template, html_template, logo when not nil
  converge_if_changed do
    availability_template_resource_init
    config = availability_template_resource.variables(:config)
    report = config.find_by_id(new_resource.report_id)
    if (report.nil?)
      config.reports << {
        id: report_id,
        type: type,
        pdf_template: pdf_template,
        svg_template: svg_template,
        html_template: html_template,
        logo: logo,
        parameters: parameters,
      }
    else
      report[:type] = new_resource.type unless new_resource.type.nil?
      # TODO: repeat for the other properties
    end
  end
end

action :create_if_missing do
  cur_reports = reports
  run_action(:create) unless cur_reports.any? { |r| r[:id] == report_id }
end

action :delete do
  cur_reports = reports
  if cur_reports.any? { |r| r[:id] == report_id }
    converge_by("Remove report #{report_id}") do
      cur_reports.reject! { |r| r[:id] == report_id }
      update_template(cur_reports)
    end
  end
end
