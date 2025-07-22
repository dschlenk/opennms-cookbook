# frozen_string_literal: true

require 'rexml/document'

module Inspec::Resources
  class AvailabilityReport < Inspec.resource(1)
    name 'availability_report'
    supports platform: 'linux'
    desc 'Use the availability_report InSpec resource to test OpenNMS availability reports'
    example <<~EXAMPLE
      describe availability_report('my-report') do
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

    def type
      return unless exists?
      @report_element.attributes['type']
    end

    def parameters
      return {} unless exists?
      params = {}
      param_elem = @report_element.elements['parameters']
      return params unless param_elem

      param_elem.elements.each do |param|
        name = param.attributes['name']
        next unless name

        param_data = param.attributes.transform_keys(&:to_s)

        if param.name == 'date-parameter'
          default_time = param.elements['default-time']
          if default_time
            param_data['default-time'] = {
              'hour' => default_time.attributes['hour'] || default_time.elements['hours']&.text,
              'minute' => default_time.attributes['minute'] || default_time.elements['minutes']&.text
            }.compact
          end
        end

        params[name] = param_data
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
  end
end
