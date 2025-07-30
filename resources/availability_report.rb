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
property :onms_home, String, default: '/opt/opennms'

default_action :create

def availability_path
  ::File.join(onms_home || '/opt/opennms', 'etc', 'availability-reports.xml')
end

def ro_resource
  run_context.resource_collection.find(template: availability_path)
rescue Chef::Exceptions::ResourceNotFound
  nil
end

def ro_init
  return if ro_resource

  config_obj = ::Opennms::Cookbook::AvailabilityReportTemplate::Helper::ReportConfig.new
  config_obj.read!(availability_path) if ::File.exist?(availability_path)
  declare_resource(:template, availability_path) do
    source 'availability-reports.xml.erb'
    cookbook 'opennms'
    owner node['opennms']['user'] || 'root'
    group node['opennms']['group'] || 'root'
    mode '0644'
    variables config_obj
    action :nothing
  end
end

load_current_value do
  availability_resource = nil
  begin
    availability_resource = run_context.resource_collection.find(template: availability_path)
  rescue Chef::Exceptions::ResourceNotFound
  end

  config_reports =
    if availability_resource
      availability_resource.variables[:config] || availability_resource.variables[:reports]
    else
      ro_init unless ro_resource
      ro_resource&.variables[:config] || ro_resource&.variables[:reports]
    end

  report = config_reports&.find { |r| r[:id] == report_id }
  current_value_does_not_exist unless report

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

  def availability_path
    ::File.join(onms_home || '/opt/opennms', 'etc', 'availability-reports.xml')
  end

  def etc
    ::File.join(node['opennms']['home'], 'etc')
  end

  def availability_path
    ::File.join(etc, 'availability-reports.xml')
  end

  def safe_get(prop)
    new_resource.public_send(prop) if new_resource.respond_to?(prop)
  end

  def availability_resource
    run_context.resource_collection.find(template: availability_path)
  rescue Chef::Exceptions::ResourceNotFound
    nil
  end

  def ro_resource
    run_context.resource_collection.find(template: availability_path)
  rescue Chef::Exceptions::ResourceNotFound
    nil
  end

  def ro_init
    return if ro_resource
    config_obj = ::Opennms::Cookbook::AvailabilityReport::Helper::ReportConfig.new
    config_obj.read!(availability_path) if ::File.exist?(availability_path)
    declare_resource(:template, availability_path) do
      source 'availability-reports.xml.erb'
      cookbook 'opennms'
      owner node['opennms']['user'] || 'root'
      group node['opennms']['group'] || 'root'
      mode '0644'
      variables config_obj
      action :nothing
    end
  end

  def reports
    node.run_state['availability_reports'] ||= []
  end

  def update_template(reports)
    tpl = availability_resource
    if tpl
      tpl.variables reports: reports
    else
      declare_resource(:template, availability_path) do
        source 'availability-reports.xml.erb'
        cookbook 'opennms'
        owner node['opennms']['user'] || 'root'
        group node['opennms']['group'] || 'root'
        mode '0644'
        variables reports: reports
        action :nothing
      end
    end
  end

  def create_aux_files
    create_template('pdf')
    create_template('svg')
    create_template('html')
    create_logo
  end

  def create_template(prefix)
    src = safe_get("#{prefix}_template_source")
    return unless src
    typ = safe_get("#{prefix}_template_type") || 'cookbook_file'
    vars = safe_get("#{prefix}_template_variables") || {}
    props = safe_get("#{prefix}_template_properties") || {}
    name = safe_get("#{prefix}_template")
    return if name.nil? || name.empty?
    tgt = ::File.join(etc, name)
    declare_resource(typ.to_sym, tgt) do
      source src
      variables vars if typ == 'template' && !vars.empty?
      props.each { |k, v| send(k, v) } if props.any?
      action :create
    end
  end

  def create_logo
    return unless safe_get(:logo)
    tgt = ::File.join(etc, safe_get(:logo))
    declare_resource(safe_get(:logo_source_type).to_sym, tgt) do
      source safe_get(:logo_source)
      vars = safe_get(:logo_source_variables)
      variables vars if safe_get(:logo_source_type) == 'template' && vars.is_a?(Hash) && !vars.empty?
      props = safe_get(:logo_source_properties)
      props&.each { |k, v| send(k, v) }
      action :create
    end
  end
end

action :create do
  converge_if_changed do
    cur_reports = reports
    cur_reports.reject! { |r| r[:id] == report_id }
    cur_reports << {
      id: report_id,
      type: type,
      pdf_template: pdf_template,
      svg_template: svg_template,
      html_template: html_template,
      logo: logo,
      parameters: parameters,
    }
    update_template(cur_reports)
    create_aux_files
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
