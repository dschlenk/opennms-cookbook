include Opennms::XmlHelper
include Opennms::Cookbook::AvailabilityReportHelper

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
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml'))
  report = config.find_report_by_id(desired.report_id)
  current_value_does_not_exist! if report.nil?

  type report[:type]
  parameters report[:parameters]
end

action_class do
  include Opennms::XmlHelper
  include ::Opennms::Cookbook::AvailabilityReportHelper

  def config_file
    ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
  end

  def create_template_file(prefix)
    template = new_resource.send("#{prefix}_template")
    source = new_resource.send("#{prefix}_template_source")
    source_type = new_resource.send("#{prefix}_template_source_type")
    variables = new_resource.send("#{prefix}_template_source_variables")
    props = new_resource.send("#{prefix}_template_source_properties")

    return if template.nil?

    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', template)

    if source
      declare_resource(source_type, target_path) do
        source source
        variables variables if source_type == 'template'
        props.each { |k, v| send(k, v) }
      end
    elsif !::File.exist?(target_path)
      raise "#{prefix}_template file '#{template}' not found in #{target_path} and no source provided"
    end
  end

  def create_logo_file
    return if new_resource.logo.nil?

    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', new_resource.logo)

    if new_resource.logo_source
      declare_resource(new_resource.logo_source_type, target_path) do
        source new_resource.logo_source
        variables new_resource.logo_source_variables if new_resource.logo_source_type == 'template'
        new_resource.logo_source_properties.each { |k, v| send(k, v) }
      end
    elsif !::File.exist?(target_path)
      raise "logo file '#{new_resource.logo}' not found in #{target_path} and no source provided"
    end
  end
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
    logo: new_resource.logo
  }

  config.add_or_update_report(config_file, report)

  converge_by("Saving availability report #{new_resource.report_id} to #{config_file}") {}

  create_template_file('pdf')
  create_template_file('svg')
  create_template_file('html')
  create_logo_file
end

action :create_if_missing do
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(config_file)
  report = config.find_report_by_id(new_resource.report_id)
  run_action(:create) if report.nil?
end

action :delete do
  config = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config.read!(config_file)

  if config.report_exists?(new_resource.report_id)
    config.delete!(config_file, new_resource.report_id)
    converge_by("Deleted availability report #{new_resource.report_id} from #{config_file}") {}
  end
end
