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
            @reports << {
              id: el.attributes['id'],
              type: el.attributes['type'],
              pdf_template: el.elements['pdf-template']&.text,
              svg_template: el.elements['svg-template']&.text,
              html_template: el.elements['html-template']&.text,
              logo: el.elements['logo']&.text,
              parameters: parse_parameters(el.elements['parameters']),
            }
          end
        end

        def report_exists?(report_id)
          @reports.any? { |r| r[:id] == report_id }
        end

        def find_by_id(report_id)
          @reports.find { |r| r[:id] == report_id }
        end

        def add_or_update_report_in_memory(report)
          idx = @reports.index { |r| r[:id] == report[:id] }
          if idx
            @reports[idx] = report
          else
            @reports << report
          end
        end

        def delete_report_in_memory(report_id)
          @reports.reject! { |r| r[:id] == report_id }
        end

        private

        def parse_parameters(params_elem)
          return {} unless params_elem

          params_hash = {}

          params_elem.elements.each('string-parm') do |el|
            params_hash[el.attributes['name']] = el.attributes.to_h.transform_keys(&:to_s)
          end

          params_elem.elements.each('date-parm') do |el|
            h = el.attributes.to_h.transform_keys(&:to_s)
            h['default-interval'] = el.elements['default-interval']&.text
            h['default-count'] = el.elements['default-count']&.text

            default_time_el = el.elements['default-time']
            if default_time_el
              h['default-time'] = if default_time_el.attributes['hour'] && default_time_el.attributes['minute']
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
            params_hash[el.attributes['name']] = el.attributes.to_h.transform_keys(&:to_s)
          end

          params_hash
        end
      end
    end

    module AvailabilityReportTemplate
      def availability_template_resource_init
        availability_template_resource_create unless availability_template_resource_exist?
      end

      def ro_availability_template_resource_init
        ro_availability_template_resource_create unless ro_availability_template_resource_exist?
      end

      def ro_availability_template_resource
        return unless ro_availability_template_resource_exist?
        find_resource!(:template, "RO #{onms_etc}/availability-reports.xml")
      end

      def availability_template_resource
        begin
          run_context.resource_collection.find(template: availability_report_path)
        rescue Chef::Exceptions::ResourceNotFound
          nil
        end
      end

      def availability_report_path
        ::File.join(node['opennms']['conf']['home'], 'etc', 'availability-reports.xml')
      end

      def availability_template_resource_create
        config = AvailabilityReportHelper::ReportConfig.new
        if ::File.exist?(availability_report_path)
          config.read!(availability_report_path)
        else
          Chef::Log.info "No availability reports config found at #{availability_report_path}, starting fresh."
        end

        with_run_context :root do
          declare_resource(:template, availability_report_path) do
            source 'availability-reports.xml.erb'
            cookbook 'opennms'
            owner node['opennms']['user'] || 'root'
            group node['opennms']['group'] || 'root'
            mode '0644'
            variables(reports: config.reports)
            action :nothing
            delayed_action :create
          end
        end
      end
    end
  end
end
