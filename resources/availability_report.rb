include ::Opennms::XmlHelper
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
  config_reports = if availability_report_template_resource = run_context.resource_collection.find(template: availability_report_path) rescue nil
                     availability_report_template_resource.variables[:config] || availability_report_template_resource.variables[:reports]
                   else
                     ro_availability_report_template_init unless ro_availability_report_template_resource
                     ro_availability_report_template_resource&.variables[:config] || ro_availability_report_template_resource&.variables[:reports]
                   end

  report = config_reports&.find { |r| r[:id] == report_id }

  current_value_does_not_exist! unless report

  type report[:type]
  parameters report[:parameters]
  pdf_template report[:pdf_template]
  svg_template report[:svg_template]
  html_template report[:html_template]
  logo report[:logo]
end

action_class do
  include ::Opennms::XmlHelper
  include ::Opennms::Cookbook::AvailabilityReportTemplate

  def etc_dir
    ::File.join(node['opennms']['home'], 'etc')
  end

  def availability_report_path
    ::File.join(etc_dir, 'availability-reports.xml')
  end

  def safe_get(prop)
    new_resource.public_send(prop) if new_resource.respond_to?(prop)
  end

  def update_template_resource!(reports)
    tpl = availability_report_template_resource
    if tpl
      tpl.variables(reports: reports)
    else
      declare_template_resource!(reports)
    end
  end

  def declare_template_resource!(reports)
    declare_resource(:template, availability_report_path) do
      source 'availability-reports.xml'
      cookbook 'opennms'
      owner node['opennms']['user'] || 'root'
      group node['opennms']['group'] || 'root'
      mode '0644'
      variables(reports: reports)
      action :nothing
      notifies :restart, 'service[opennms]', :delayed
    end
  end

  def reports_collection
    node.run_state['availability_reports'] ||= []
  end

  def availability_report_template_resource
    run_context.resource_collection.find(template: availability_report_path)
  rescue Chef::Exceptions::ResourceNotFound
    nil
  end

  def create_auxiliary_files
    create_template_file('pdf')
    create_template_file('svg')
    create_template_file('html')
    create_logo_file
  end

  def create_template_file(prefix)
    template_name = safe_get("#{prefix}_template")
    return if template_name.nil? || template_name.empty?

    source = safe_get("#{prefix}_source") || safe_get("#{prefix}_template_source")
    return unless source

    source_type = safe_get("#{prefix}_source_type") || 'cookbook_file'
    source_type_sym = source_type.to_sym

    variables = safe_get("#{prefix}_source_variables") || {}
    properties = safe_get("#{prefix}_source_properties") || {}

    path = ::File.join(etc_dir, template_name)

    declare_resource(source_type_sym, path) do
      source source
      variables(variables) if source_type == 'template' && !variables.empty?
      properties.each { |k, v| send(k, v) } unless properties.empty?
      action :create
    end
  end

  def create_logo_file
    return if safe_get(:logo).nil? || safe_get(:logo).empty?

    path = ::File.join(etc_dir, safe_get(:logo))

    declare_resource(safe_get(:logo_source_type).to_sym, path) do
      source safe_get(:logo_source) if safe_get(:logo_source)
      variables(safe_get(:logo_source_variables)) if safe_get(:logo_source_type) == 'template' && !safe_get(:logo_source_variables).empty?
      safe_get(:logo_source_properties).each { |k, v| send(k, v) } if safe_get(:logo_source_properties) && !safe_get(:logo_source_properties).empty?
      action :create
    end
  end
end

action :create do
  converge_if_changed do
    reports = reports_collection
    reports.reject! { |r| r[:id] == new_resource.report_id }
    reports << {
      id: new_resource.report_id,
      type: new_resource.type,
      pdf_template: new_resource.pdf_template,
      svg_template: new_resource.svg_template,
      html_template: new_resource.html_template,
      logo: new_resource.logo,
      parameters: new_resource.parameters
    }

    update_template_resource!(reports)

    create_auxiliary_files
  end
end

action :create_if_missing do
  reports = reports_collection
  run_action(:create) unless reports.any? { |r| r[:id] == new_resource.report_id }
end

action :delete do
  reports = reports_collection
  if reports.any? { |r| r[:id] == new_resource.report_id }
    converge_by "Removing availability report #{new_resource.report_id}" do
      reports.reject! { |r| r[:id] == new_resource.report_id }
      update_template_resource!(reports)
    end
  end
end
