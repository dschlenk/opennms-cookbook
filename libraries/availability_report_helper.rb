module Opennms
  module Cookbook
    module AvailabilityReportHelper
      class ReportConfig
        attr_reader :data

        def initialize
          @data = { reports: [] }
        end

        def read!(file_path)
          edit_xml_file(file_path) do |doc|
            doc.elements.each('opennms-reports/report') do |el|
              report = {
                id: el.attributes['id'],
                type: el.attributes['type'],
                pdf_template: el.elements['pdf-template']&.text,
                svg_template: el.elements['svg-template']&.text,
                html_template: el.elements['html-template']&.text,
                logo: el.elements['logo']&.text,
                parameters: {},
              }

              @data[:reports] << report
            end
          end
        end

        def report_exists?(report_id)
          @data[:reports].any? { |r| r[:id] == report_id }
        end

        def find_report_by_id(report_id)
          @data[:reports].find { |report| report[:id] == report_id }
        end

        def create!(file_path, new_report)
          edit_xml_file(file_path) do |doc|
            root = doc.root

            report_el = REXML::Element.new('report')
            report_el.add_attributes('id' => new_report[:id], 'type' => new_report[:type])

            %i[pdf_template svg_template html_template logo].each do |field|
              next unless new_report[field]

              child = REXML::Element.new(field.to_s.tr('_', '-'))
              child.text = new_report[field]
              report_el.add_element(child)
            end

            report_el.add_element(build_parameters(new_report[:parameters])) if new_report[:parameters]
            root.add_element(report_el)
          end
        end

        def update!(file_path, updated_report)
          edit_xml_file(file_path) do |doc|
            doc.elements.each('opennms-reports/report') do |el|
              next unless el.attributes['id'] == updated_report[:id]

              el.attributes['type'] = updated_report[:type]

              %w[pdf-template svg-template html-template logo].each do |tag|
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

              el.delete_element('parameters')
              el.add_element(build_parameters(updated_report[:parameters])) if updated_report[:parameters]
            end
          end
        end

        def delete!(file_path, report_id)
          edit_xml_file(file_path) do |doc|
            doc.elements.each('opennms-reports/report') do |el|
              if el.attributes['id'] == report_id
                doc.root.delete_element(el)
                break
              end
            end
          end
        end

        private

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
          yield(doc)

          formatter = REXML::Formatters::Pretty.new(2)
          formatter.compact = true
          output = ''
          formatter.write(doc, output)
          ::File.write(path, output)
          doc
        end
      end
    end
  end
end
