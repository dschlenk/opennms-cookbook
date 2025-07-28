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
allowed_actions :create, :create_if_missing, :delete

action_class do
  include Opennms::XmlHelper
  include ::Opennms::Cookbook::AvailabilityReportTemplate

  def etc_dir
    ::File.join(node['opennms']['conf']['home'], 'etc')
  end

  def config_file
    ::File.join(etc_dir, 'availability-reports.xml')
  end

  def create_template_file(prefix)
    template_name = new_resource.send("#{prefix}_template")
    source = new_resource.send("#{prefix}_template_source")
    source_type = new_resource.send("#{prefix}_template_source_type").to_sym
    variables = new_resource.send("#{prefix}_template_source_variables")
    props = new_resource.send("#{prefix}_template_source_properties")

    return if template_name.nil?

    target_path = ::File.join(etc_dir, template_name)

    if source
      declare_resource(source_type, target_path) do
        source source
        variables variables if source_type == :template && !variables.empty?
        props.each { |k, v| send(k, v) }
        action :create
      end
    elsif !::File.exist?(target_path)
      raise Chef::Exceptions::FileNotFound,
            "#{prefix}_template file '#{template_name}' not found at #{target_path} and no source provided"
    end
  end

  def create_logo_file
    return if new_resource.logo.nil?

    target_path = ::File.join(etc_dir, new_resource.logo)

    if new_resource.logo_source
      declare_resource(new_resource.logo_source_type.to_sym, target_path) do
        source new_resource.logo_source
        variables new_resource.logo_source_variables if new_resource.logo_source_type == 'template' && !new_resource.logo_source_variables.empty?
        new_resource.logo_source_properties.each { |k, v| send(k, v) }
        action :create
      end
    elsif !::File.exist?(target_path)
      raise Chef::Exceptions::FileNotFound,
            "logo file '#{new_resource.logo}' not found at #{target_path} and no source provided"
    end
  end
end

load_current_value do |desired|
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml'))
  report = config.find_report_by_id(desired.report_id)
  current_value_does_not_exist! if report.nil?

  type report[:type]
  parameters report[:parameters]
  pdf_template report[:pdf_template]
  svg_template report[:svg_template]
  html_template report[:html_template]
  logo report[:logo]
end

action :create do
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(config_file)

  report = {
    id: new_resource.report_id,
    type: new_resource.type,
    parameters: new_resource.parameters,
    pdf_template: new_resource.pdf_template,
    svg_template: new_resource.svg_template,
    html_template: new_resource.html_template,
    logo: new_resource.logo,
  }

  converge_by("Saving availability report #{new_resource.report_id} to #{config_file}") do
    config.add_or_update_report(config_file, report)
  end

  availability_reports_resource_create  # declares the template resource with delayed action to write file

  create_template_file('pdf')
  create_template_file('svg')
  create_template_file('html')
  create_logo_file
end

action :create_if_missing do
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(config_file)
  run_action(:create) unless config.report_exists?(new_resource.report_id)
end

action :delete do
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(config_file)
  if config.report_exists?(new_resource.report_id)
    converge_by("Deleted availability report #{new_resource.report_id} from #{config_file}") do
      config.delete!(config_file, new_resource.report_id)
    end
    availability_reports_resource_create
  end
end
