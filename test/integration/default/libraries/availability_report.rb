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
      @content = nil
      @report_element = nil
      read_report
    end

    def exists?
      !@report_element.nil?
    end

    def type
      return nil unless exists?
      @report_element.attributes['type']
    end

    def parameters
      return nil unless exists?
      params = {}
      param_elem = @report_element.elements['parameters']
      return params unless param_elem

      param_elem.elements.each do |param|
        name = param.attributes['name']
        params[name] = param.attributes
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
