# frozen_string_literal: true

require 'rexml/document'

module Inspec::Resources
  class AvailabilityReport < Inspec.resource(1)
    name 'availability_report'
    supports platform: 'linux'
    desc 'Resource to verify OpenNMS availability reports'

    example <<~EXAMPLE
      describe availability_report('foo') do
        it { should exist }
        its('type') { should cmp 'calendar' }
      end
    EXAMPLE

    def initialize(report_id)
      @report_id = report_id
      @file_path = '/opt/opennms/etc/availability-reports.xml'
      @report_element = nil
      read_report
    end

    def exists?
      !@report_element.nil?
    end
    alias exist? exists?

    def type
      return unless exists?

      @report_element.attributes['type']
    end

    def parameters
      return {} unless exists?

      params = {}
      param_elem = @report_element.elements['parameters']
      return params unless param_elem

      %w(string-parm date-parm int-parm).each do |parm_type|
        param_elem.elements.each(parm_type) do |el|
          name = el.attributes['name']
          next unless name

          params[name] = extract_parameter_details(el, parm_type)
        end
      end

      params
    end

    private

    def read_report
      return unless File.exist?(@file_path)

      file = File.read(@file_path)
      doc = REXML::Document.new(file)
      @report_element = REXML::XPath.first(doc, "//report[@id='#{@report_id}']")
    rescue REXML::ParseException => e
      skip_resource "Could not parse #{@file_path}: #{e.message}"
    end

    def extract_parameter_details(el, parm_type)
      case parm_type
      when 'string-parm', 'int-parm'
        {
          'name' => el.attributes['name'] || '',
          'display-name' => el.attributes['display-name'] || '',
          'input-type' => el.attributes['input-type'] || '',
          'default' => el.attributes['default'] || '',
        }
      when 'date-parm'
        default_time_el = el.elements['default-time']
        default_time_hash = if default_time_el
                              {
                                'hour' => default_time_el.attributes['hour'] || default_time_el.elements['hours']&.text || '',
                                'minute' => default_time_el.attributes['minute'] || default_time_el.elements['minutes']&.text || '',
                              }
                            else
                              {}
                            end

        {
          'name' => el.attributes['name'] || '',
          'display-name' => el.attributes['display-name'] || '',
          'use-absolute-date' => el.attributes['use-absolute-date'] || '',
          'default-interval' => el.elements['default-interval']&.text || '',
          'default-count' => el.elements['default-count']&.text || '',
          'default-time' => default_time_hash,
        }
      else
        {}
      end
    end
  end
end
