module Opennms
  module Cookbook
    module ConfigHelpers
      module AvailabilityReportTemplate
        class Report
          attr_accessor :id, :type, :parameters

          def initialize(id:, type:, parameters: {})
            @id = id
            @type = type
            @parameters = parameters
          end

          def update(type:, parameters:)
            @type = type unless type.nil?
            @parameters = parameters unless parameters.nil?
          end
        end

        class ReportConfig
          include Opennms::XmlHelper

          def initialize
            @data = { reports: [] }
            Chef::Log.debug('[ReportConfig] Initialized with empty report list.')
          end

          def read!(file)
            Chef::Log.info("[ReportConfig] Reading availability reports from: #{file}")
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

            edit_xml_file(file) do |doc|
              doc.xpath('//report').each do |report_el|
                id = report_el['id']
                type = report_el['type']
                parameters = parse_parameters(report_el)

                report = Report.new(id: id, type: type, parameters: parameters)
                Chef::Log.debug("[ReportConfig] Loaded report: #{id}")
                @data[:reports] << report
              end
            end

            Chef::Log.info("[ReportConfig] Finished reading. Total reports: #{@data[:reports].size}")
          end

          def reports
            @data[:reports]
          end

          def find_report_by_id(id)
            Chef::Log.debug("[ReportConfig] Searching for report: #{id}")
            found = reports.find { |r| r.id == id }
            Chef::Log.debug("[ReportConfig] Found report: #{found.inspect}") if found
            found
          end

          def delete_report(id)
            Chef::Log.info("[ReportConfig] Deleting report: #{id}")
            before = @data[:reports].size
            @data[:reports].reject! { |r| r.id == id }
            after = @data[:reports].size
            Chef::Log.info("[ReportConfig] Deleted #{before - after} report(s).")
          end

          def add_or_update_report(new_report)
            existing = find_report_by_id(new_report.id)
            if existing
              Chef::Log.info("[ReportConfig] Updating existing report: #{new_report.id}")
              existing.update(type: new_report.type, parameters: new_report.parameters)
            else
              Chef::Log.info("[ReportConfig] Adding new report: #{new_report.id}")
              @data[:reports] << new_report
            end
          end

          def to_hash
            @data
          end

          private

          def parse_parameters(report_el)
            param_el = report_el.at_xpath('parameters')
            return {} unless param_el

            {
              string_parms: param_el.xpath('string-parameter').map do |el|
                {
                  name: el['name'],
                  display_name: el['display-name'],
                  input_type: el['input-type'],
                  default: el['default']
                }.compact
              end,
              date_parms: param_el.xpath('date-parameter').map do |el|
                default_time = el.at_xpath('default-time')
                {
                  name: el['name'],
                  display_name: el['display-name'],
                  use_absolute_date: el['use-absolute-date'] == 'true',
                  default_interval: el['default-interval'],
                  default_count: el['default-count'].to_i,
                  default_time: default_time ? {
                    hour: default_time['hour'].to_i,
                    minute: default_time['minute'].to_i
                  } : nil
                }.compact
              end,
              int_parms: param_el.xpath('int-parameter').map do |el|
                {
                  name: el['name'],
                  display_name: el['display-name'],
                  input_type: el['input-type'],
                  default: el['default']&.to_i
                }.compact
              end
            }
          end
        end
      end
    end
  end
end
