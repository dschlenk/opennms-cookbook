# frozen_string_literal: true

require 'rexml/document'

module Inspec::Resources
  class AvailabilityReport < Inspec.resource(1)
    name 'availability_report'
    supports platform: 'linux'
    desc 'Use the availability_report InSpec resource to test OpenNMS availability reports'
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

    def type
      return unless exists?

      @report_element.attributes['type']
    end

    def parameters
      return {} unless exists?

      params = {}
      param_elem = @report_element.elements['parameters']
      return params unless param_elem

      param_elem.elements.each('string-parm') do |el|
        name = el.attributes['name']
        next unless name

        params[name] = {
          'name' => name,
          'display-name' => el.attributes['display-name'],
          'input-type' => el.attributes['input-type'],
          'default' => el.attributes['default'],
        }.compact
      end

      param_elem.elements.each('date-parm') do |el|
        name = el.attributes['name']
        next unless name

        default_time = el.elements['default-time']
        default_time_hash = nil

        if default_time
          default_time_hash = {
            'hour' => default_time.attributes['hour'] || default_time.elements['hours']&.text,
            'minute' => default_time.attributes['minute'] || default_time.elements['minutes']&.text,
          }
        end

        params[name] = {
          'name' => name,
          'display-name' => el.attributes['display-name'],
          'use-absolute-date' => el.attributes['use-absolute-date'],
          'default-interval' => el.elements['default-interval']&.text,
          'default-count' => el.elements['default-count']&.text,
          'default-time' => default_time_hash,
        }.compact
      end

      param_elem.elements.each('int-parm') do |el|
        name = el.attributes['name']
        next unless name

        params[name] = {
          'name' => name,
          'display-name' => el.attributes['display-name'],
          'input-type' => el.attributes['input-type'],
          'default' => el.attributes['default'],
        }.compact
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
