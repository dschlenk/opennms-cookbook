include Opennms::XmlHelper
include Opennms::Cookbook::ConfigHelpers::AvailabilityReportTemplate

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
  edit_xml_file ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml') do
    xpath '/reports'
    action :edit
    block do |doc|
      report = doc.at_xpath("//report[@id='#{desired.report_id}']")
      current_value_does_not_exist! if report.nil?
      type report['type']
    end
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

    target_path = ::File.join(node['opennms']['conf']['home'], 'etc', template) if template

    if source
      send(source_type, target_path) do
        source source
        variables variables if source_type == 'template'
        props.each { |k, v| send(k, v) }
      end
    elsif template && !::File.exist?(target_path)
      raise "#{type}_template file #{template} not found and no source provided"
    end
  end

  def build_parameters_xml(doc, report_elem)
    return unless new_resource.parameters

    params = new_resource.parameters
    return if params.empty?

    param_elem = doc.create_element('parameters')

    Array(params['string_parms']).each do |sp|
      string_elem = doc.create_element('string-parameter')
      string_elem['name'] = sp['name']
      string_elem['display-name'] = sp['display_name']
      string_elem['input-type'] = sp['input_type']
      string_elem['default'] = sp['default'] if sp['default']
      param_elem.add_child(string_elem)
    end

    Array(params['date_parms']).each do |dp|
      date_elem = doc.create_element('date-parameter')
      date_elem['name'] = dp['name']
      date_elem['display-name'] = dp['display_name']
      date_elem['use-absolute-date'] = dp['use_absolute_date'].to_s if dp.key?('use_absolute_date')
      date_elem['default-interval'] = dp['default_interval']
      date_elem['default-count'] = dp['default_count'].to_s
      if dp['default_time']
        time_elem = doc.create_element('default-time')
        time_elem['hour'] = dp['default_time']['hour'].to_s
        time_elem['minute'] = dp['default_time']['minute'].to_s
        date_elem.add_child(time_elem)
      end
      param_elem.add_child(date_elem)
    end

    Array(params['int_parms']).each do |ip|
      int_elem = doc.create_element('int-parameter')
      int_elem['name'] = ip['name']
      int_elem['display-name'] = ip['display_name']
      int_elem['input-type'] = ip['input_type']
      int_elem['default'] = ip['default'].to_s if ip.key?('default')
      param_elem.add_child(int_elem)
    end

    report_elem.add_child(param_elem)
  end
end

action :create do
  converge_if_changed do
    edit_xml_file config_file do
      xpath '/reports'
      action :edit
      block do |doc|
        doc.xpath("//report[@id='#{new_resource.report_id}']").each(&:remove)

        report_elem = doc.create_element('report')
        report_elem['id'] = new_resource.report_id
        report_elem['type'] = new_resource.type

        build_parameters_xml(doc, report_elem)

        doc.root.add_child(report_elem)
      end
    end
  end

  %w[pdf svg html logo].each do |type|
    validate_or_create_file(type)
  end
end

action :create_if_missing do
  found = false
  edit_xml_file config_file do
    xpath '/reports'
    action :edit
    block do |doc|
      found = !doc.at_xpath("//report[@id='#{new_resource.report_id}']").nil?
    end
  end
  run_action(:create) unless found
end

action :delete do
  edit_xml_file config_file do
    xpath '/reports'
    action :edit
    block do |doc|
      node = doc.at_xpath("//report[@id='#{new_resource.report_id}']")
      node.remove if node
    end
  end
end
