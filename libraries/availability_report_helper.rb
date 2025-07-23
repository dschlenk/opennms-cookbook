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

              el.elements.each('parameter') do |param|
                report[:parameters][param.attributes['key']] = param.text
              end

              @data[:reports] << report
            end
          end
        end

        def report_exists?(report_id)
          @data[:reports].any? { |r| r[:id] == report_id }
        end

        def create!(file_path, new_report)
          edit_xml_file(file_path) do |doc|
            root = doc.root

            report_el = REXML::Element.new('report')
            report_el.add_attributes(
              'id' => new_report[:id],
              'type' => new_report[:type]
            )

            %i(pdf_template svg_template html_template logo).each do |field|
              next unless new_report[field]

              child = REXML::Element.new(field.to_s.tr('_', '-'))
              child.text = new_report[field]
              report_el.add_element(child)
            end

            if new_report[:parameters]
              new_report[:parameters].each do |k, v|
                param_el = REXML::Element.new('parameter')
                param_el.add_attribute('key', k)
                param_el.text = v
                report_el.add_element(param_el)
              end
            end

            root.add_element(report_el)
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

              el.elements.delete_all('parameter')
              next unless updated_report[:parameters]

              updated_report[:parameters].each do |k, v|
                param_el = REXML::Element.new('parameter')
                param_el.add_attribute('key', k)
                param_el.text = v
                el.add_element(param_el)
              end
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
