include Opennms::XmlHelper
include Opennms::Cookbook::AvailabilityReportHelper
include Opennms::Cookbook::AvailabilityReportTemplate

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
             availability_template_resource.variables[:config]
           else
             ro_availability_template_resource_init
             ro_availability_template_resource.variables[:config]
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
  include Opennms::Cookbook::AvailabilityReportHelper
  include Opennms::Cookbook::AvailabilityReportTemplate
end

action :create do
  def create_template_file(path, source_type, source, variables, properties)
    Chef::Log.debug("Creating #{source_type} at #{path} with source #{source}")
    case source_type
    when 'cookbook_file'
      cookbook_file path do
        source source
        properties.each { |k, v| send(k, v) }
      end
    when 'template'
      template path do
        source source
        variables variables
        properties.each { |k, v| send(k, v) }
      end
    when 'remote_file'
      remote_file path do
        source source
        properties.each { |k, v| send(k, v) }
      end
    end
  end

  %w(pdf svg html).each do |kind|
    begin
      Chef::Log.debug("Processing template kind: #{kind}")
      template_value = new_resource.send("#{kind}_template")
      source = new_resource.send("#{kind}_template_source")
      source_type = new_resource.send("#{kind}_template_source_type")
      variables = new_resource.send("#{kind}_template_source_variables")
      properties = new_resource.send("#{kind}_template_source_properties")

      next if template_value.nil?

      path = ::File.join(new_resource.onms_home, 'etc', 'report-templates', template_value)

      if source.nil? && !::File.exist?(path)
        raise "Template file #{path} does not exist and no source was provided."
      end

      create_template_file(path, source_type, source, variables, properties) unless source.nil?
    rescue NoMethodError => e
      raise "Missing property for kind '#{kind}': #{e.message}"
    end
  end

  unless new_resource.logo.nil?
    path = ::File.join(new_resource.onms_home, 'etc', 'report-templates', new_resource.logo)
    if new_resource.logo_source.nil? && !::File.exist?(path)
      raise "Logo file #{path} does not exist and no source was provided."
    end

    create_template_file(
      path,
      new_resource.logo_source_type,
      new_resource.logo_source,
      new_resource.logo_source_variables,
      new_resource.logo_source_properties
    ) unless new_resource.logo_source.nil?
  end

  converge_if_changed do
    availability_template_resource_init
    config = availability_template_resource.variables[:config]
    report = config.find_by_id(new_resource.report_id)

    if report.nil?
      config.reports << {
        id: new_resource.report_id,
        type: new_resource.type,
        pdf_template: new_resource.pdf_template,
        svg_template: new_resource.svg_template,
        html_template: new_resource.html_template,
        logo: new_resource.logo,
        parameters: new_resource.parameters,
      }
    else
      report[:type] = new_resource.type unless new_resource.type.nil?
      report[:pdf_template] = new_resource.pdf_template unless new_resource.pdf_template.nil?
      report[:svg_template] = new_resource.svg_template unless new_resource.svg_template.nil?
      report[:html_template] = new_resource.html_template unless new_resource.html_template.nil?
      report[:logo] = new_resource.logo unless new_resource.logo.nil?
      report[:parameters] = new_resource.parameters unless new_resource.parameters.nil?
    end
  end
end

end

action :create_if_missing do
  cur_reports = reports
  run_action(:create) unless cur_reports.any? { |r| r[:id] == report_id }
end

action :delete do
  availability_template_resource_init
  config = availability_template_resource.variables[:config]
  report = config.find_by_id(new_resource.report_id)
  unless report.nil?
    converge_by("Remove report #{report_id}") do
      config.reports.reject! { |r| r[:id] == report_id }
      update_template(config.reports)
    end
  end
end
