# frozen_string_literal: true

require 'nokogiri'

class JmsNbDestination < Inspec.resource(1)
  name 'jms_nb_destination'

  desc 'Custom resource to test OpenNMS JMS Northbounder destinations'

  example <<~EXAMPLE
    describe jms_nb_destination('SingleAlarmQueue') do
      it { should exist }
      its('first_occurrence_only') { should eq true }
      its('send_as_object_message') { should eq false }
      its('destination_type') { should eq 'QUEUE' }
      its('message_format') { should eq 'ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}' }
    end
  EXAMPLE

  def initialize(destination_name)
    @destination_name = destination_name
    @file_path = '/opt/opennms/etc/jms-northbounder-configuration.xml'
    @exists = false
    @properties = {}

    parse_config if inspec.file(@file_path).exist?
  end

  def exist?
    @exists
  end

  def first_occurrence_only
    @properties['first-occurrence-only']
  end

  def send_as_object_message
    @properties['send-as-object-message']
  end

  def destination_type
    @properties['destination-type']
  end

  def message_format
    @properties['message-format']
  end

  def to_s
    "JMS Destination #{@destination_name}"
  end

  private

  def parse_config
    content = inspec.file(@file_path).content
    puts "[DEBUG] Parsing JMS config from #{@file_path}"
    puts content

    doc = Nokogiri::XML(content)
    doc.xpath('//destination').each do |dest|
      name = dest.at_xpath('jms-destination')&.text
      next unless name == @destination_name

      @exists = true
      @properties['first-occurrence-only'] = dest.at_xpath('first-occurrence-only')&.text == 'true'
      @properties['send-as-object-message'] = dest.at_xpath('send-as-object-message')&.text == 'true'
      @properties['destination-type'] = dest.at_xpath('destination-type')&.text || 'QUEUE'
      @properties['message-format'] = dest.at_xpath('message-format')&.text
    end
  end
end
