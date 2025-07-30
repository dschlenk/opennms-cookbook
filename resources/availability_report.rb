include Opennms::XmlHelper
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

default_action :create

load_current_value do
  config_obj = ::Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new
  config_obj.read!(config_file)

  report = config_obj.find_by_id(report_id)
  current_value_does_not_exist! unless report

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

  def config_file
    ::File.join(etc_dir, 'availability-reports.xml')
  end

  def reports_collection
    node.run_state['availability_reports'] ||= []
  end

  def availability_template_resource
    run_context.resource_collection.find(template: config_file)
  rescue Chef::Exceptions::ResourceNotFound
    nil
  end

  def update_template_resource(reports)
    tr = availability_template_resource
    if tr
      tr.variables(reports: reports)
    else
      template config_file do
        source 'availability-reports.xml.erb'
        cookbook 'opennms'
        owner node['opennms']['user'] || 'root'
        group node['opennms']['group'] || 'root'
        mode '0644'
        variables(reports: reports)
        action :nothing
        notifies :restart, 'service[opennms]', :delayed
      end
    end
  end

  def create_auxiliary_files
    create_template_file('pdf')
    create_template_file('svg')
    create_template_file('html')
    create_logo_file
  end

  def create_template_file(prefix)
    source = safe_send("#{prefix}_template_source")
    return unless source

    source_type = safe_send("#{prefix}_template_source_type")
    variables = safe_send("#{prefix}_template_source_variables") || {}
    properties = safe_send("#{prefix}_template_source_properties") || {}
    template_name = safe_send("#{prefix}_template")

    return if template_name.nil? || template_name.empty? || source.nil? || source_type.nil?

    target_path = ::File.join(etc_dir, template_name)

    declare_resource(source_type.to_sym, target_path) do
      source source
      variables(variables) if source_type.to_s == 'template' && !variables.empty?
      properties.each { |k, v| send(k, v) } if !properties.empty?
      action :create
    end
  end

  def create_logo_file
    return if new_resource.logo.nil? || new_resource.logo.empty?

    target_path = ::File.join(etc_dir, new_resource.logo)

    declare_resource(new_resource.logo_source_type.to_sym, target_path) do
      source new_resource.logo_source if new_resource.logo_source
      variables(new_resource.logo_source_variables) if new_resource.logo_source_type.to_s == 'template' && !new_resource.logo_source_variables.empty?
      new_resource.logo_source_properties.each { |k, v| send(k, v) } if !new_resource.logo_source_properties.empty?
      action :create
    end
  end

  def safe_send(property)
    new_resource.send(property)
  rescue NoMethodError
    nil
  end
end

action :create do
  reports_collection.reject! { |r| r[:id] == new_resource.report_id }

  reports_collection << {
    id: new_resource.report_id,
    type: new_resource.type,
    pdf_template: new_resource.pdf_template,
    svg_template: new_resource.svg_template,
    html_template: new_resource.html_template,
    logo: new_resource.logo,
    parameters: new_resource.parameters
  }

  update_template_resource(reports_collection)

  converge_if_changed do
    create_auxiliary_files
  end
end

action :create_if_missing do
  unless reports_collection.any? { |r| r[:id] == new_resource.report_id }
    action_create
  end
end

action :delete do
  if reports_collection.any? { |r| r[:id] == new_resource.report_id }
    reports_collection.reject! { |r| r[:id] == new_resource.report_id }
    update_template_resource(reports_collection)
  end
end
