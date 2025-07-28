module Opennms
  module Cookbook
    module AvailabilityReportHelper
      class ReportConfig
        attr_reader :reports

        def initialize
          @reports = []
        end

        def read!(file_path)
          raise "Config file '#{file_path}' does not exist" unless ::File.exist?(file_path)

          content = ::File.read(file_path)
          doc = REXML::Document.new(content)

          @reports.clear

          doc.elements.each('opennms-reports/report') do |el|
            report = {
              id: el.attributes['id'],
              type: el.attributes['type'],
              pdf_template: el.elements['pdf-template']&.text,
              svg_template: el.elements['svg-template']&.text,
              html_template: el.elements['html-template']&.text,
              logo: el.elements['logo']&.text,
              parameters: parse_parameters(el.elements['parameters']),
            }
            @reports << report
          end
        end

        def report_exists?(report_id)
          @reports.any? { |r| r[:id] == report_id }
        end

        def find_report_by_id(report_id)
          @reports.find { |r| r[:id] == report_id }
        end

        def add_or_update_report(file_path, new_report)
          if report_exists?(new_report[:id])
            update!(file_path, new_report)
          else
            create!(file_path, new_report)
          end
          true
        end

        def delete!(file_path, report_id)
          edit_xml_file(file_path) do |doc|
            reports = doc.elements.to_a('opennms-reports/report')
            reports.each do |el|
              next unless el.attributes['id'] == report_id

              doc.root.delete_element(el)
              @reports.delete_if { |r| r[:id] == report_id }
              break
            end
          end
        end

        private

        def create!(file_path, new_report)
          edit_xml_file(file_path) do |doc|
            root = doc.root
            report_el = REXML::Element.new('report')
            report_el.add_attributes('id' => new_report[:id], 'type' => new_report[:type])
            add_optional_children(report_el, new_report)
            root.add_element(report_el)
            @reports << new_report
          end
        end

        def update!(file_path, updated_report)
          edit_xml_file(file_path) do |doc|
            doc.elements.each('opennms-reports/report') do |el|
              next unless el.attributes['id'] == updated_report[:id]

              el.attributes['type'] = updated_report[:type]

              %w(pdf-template svg-template html-template logo).each do |tag|
                child = el.elements[tag]
                value = updated_report[tag.tr('-', '_').to_sym]
                if value
                  if child
                    child.text = value
                  else
                    new_child = REXML::Element.new(tag)
                    new_child.text = value
                    el.add_element(new_child)
                  end
                elsif child
                  el.delete_element(child)
                end
              end

              el.delete_element('parameters') if el.elements['parameters']
              el.add_element(build_parameters(updated_report[:parameters])) if updated_report[:parameters]

              idx = @reports.find_index { |r| r[:id] == updated_report[:id] }
              @reports[idx] = updated_report if idx
            end
          end
        end

        def add_optional_children(report_el, report_hash)
          %i(pdf_template svg_template html_template logo).each do |key|
            next unless report_hash[key]

            child = REXML::Element.new(key.to_s.tr('_', '-'))
            child.text = report_hash[key]
            report_el.add_element(child)
          end
          report_el.add_element(build_parameters(report_hash[:parameters])) if report_hash[:parameters]
        end

        def parse_parameters(params_elem)
          return {} if params_elem.nil?

          params_hash = {}

          params_elem.elements.each('string-parm') do |el|
            params_hash[el.attributes['name']] = el.attributes.transform_keys(&:to_s)
          end

          params_elem.elements.each('date-parm') do |el|
            h = el.attributes.transform_keys(&:to_s)
            h['default-interval'] = el.elements['default-interval']&.text
            h['default-count'] = el.elements['default-count']&.text

            default_time_el = el.elements['default-time']
            if default_time_el
              h['default-time'] =
                if default_time_el.attributes['hour'] && default_time_el.attributes['minute']
                  {
                    'hour' => default_time_el.attributes['hour'],
                    'minute' => default_time_el.attributes['minute'],
                  }
                else
                  {
                    'hour' => default_time_el.elements['hours']&.text,
                    'minute' => default_time_el.elements['minutes']&.text,
                  }
                end
            end

            params_hash[el.attributes['name']] = h
          end

          params_elem.elements.each('int-parm') do |el|
            params_hash[el.attributes['name']] = el.attributes.transform_keys(&:to_s)
          end

          params_hash
        end

        def build_parameters(params)
          params_el = REXML::Element.new('parameters')

          (params['string_parms'] || []).each do |sp|
            el = REXML::Element.new('string-parm')
            el.add_attributes(
              'name' => sp['name'],
              'display-name' => sp['display_name'],
              'input-type' => sp['input_type']
            )
            el.add_attribute('default', sp['default']) if sp.key?('default')
            params_el.add_element(el)
          end

          (params['date_parms'] || []).each do |dp|
            el = REXML::Element.new('date-parm')
            el.add_attributes(
              'name' => dp['name'],
              'display-name' => dp['display_name']
            )
            el.add_attribute('use-absolute-date', dp['use_absolute_date'].to_s) if dp.key?('use_absolute_date')

            interval = REXML::Element.new('default-interval')
            interval.text = dp['default_interval']
            el.add_element(interval)

            count = REXML::Element.new('default-count')
            count.text = dp['default_count'].to_s
            el.add_element(count)

            if dp['default_time']
              dt = REXML::Element.new('default-time')
              hour = REXML::Element.new('hours')
              hour.text = dp['default_time']['hour'].to_s
              minute = REXML::Element.new('minutes')
              minute.text = dp['default_time']['minute'].to_s
              dt.add_element(hour)
              dt.add_element(minute)
              el.add_element(dt)
            end

            params_el.add_element(el)
          end

          (params['int_parms'] || []).each do |ip|
            el = REXML::Element.new('int-parm')
            el.add_attributes(
              'name' => ip['name'],
              'display-name' => ip['display_name'],
              'input-type' => ip['input_type']
            )
            el.add_attribute('default', ip['default'].to_s) if ip.key?('default')
            params_el.add_element(el)
          end

          params_el
        end

        def edit_xml_file(path)
          content = ::File.read(path)
          doc = REXML::Document.new(content)
          yield(doc) if block_given?

          formatter = REXML::Formatters::Pretty.new(2)
          formatter.compact = true
          output = ''
          formatter.write(doc, output)
          ::File.write(path, output)
          doc
        end
      end
    end

    module AvailabilityReportTemplate
      def availability_reports_resource_init
        availability_reports_resource_create unless availability_reports_resource_exist?
      end

      def availability_reports_resource
        return unless availability_reports_resource_exist?

        find_resource!(:template, availability_reports_config_path)
      end

      def availability_reports_resource_exist?
        !find_resource(:template, availability_reports_config_path).nil?
      rescue Chef::Exceptions::ResourceNotFound
        false
      end

      def availability_reports_config_path
        ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
      end

      def availability_reports_resource_create
        config_path = availability_reports_config_path
        config = Opennms::Cookbook::AvailabilityReportHelper::ReportConfig.new

        if ::File.exist?(config_path)
          Chef::Log.info("[AvailabilityReportTemplate] Reading existing config from: #{config_path}")
          config.read!(config_path)
        else
          Chef::Log.warn("[AvailabilityReportTemplate] Config file #{config_path} does not exist, initializing empty config.")
        end

        with_run_context :root do
          declare_resource(:template, config_path) do
            source 'availability-reports.xml.erb'
            cookbook 'opennms'
            owner node['opennms']['username']
            group node['opennms']['groupname']
            mode '0644'
            variables(reports: config.reports)
            action :nothing
            delayed_action :create
            notifies :restart, 'service[opennms]', :delayed
          end
        end
      end
    end
  end
end
