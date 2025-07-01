# frozen_string_literal: true

require 'rexml/document'

class JmsNbDestination < Inspec.resource(1)
  name 'jms_nb_destination'

  desc 'Custom resource to test OpenNMS JMS Northbounder destinations'

  example <<~EXAMPLE
    describe jms_nb_destination('SingleAlarmQueue') do
      it { should exist }
      its('first_occurence_only') { should eq true }
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

  def first_occurence_only
    @properties['first-occurence-only']
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

  private

  def parse_config
    content = inspec.file(@file_path).content
    doc = REXML::Document.new(content)
    doc.elements.each('jms-northbounder-config/destination') do |dest|
      name = dest.elements['jms-destination']&.text
      next unless name == @destination_name

      @exists = true
      @properties['first-occurence-only'] = dest.elements['first-occurence-only']&.text == 'true'
      @properties['send-as-object-message'] = dest.elements['send-as-object-message']&.text == 'true'
      @properties['destination-type'] = dest.attributes['type'] || 'QUEUE'
      @properties['message-format'] = dest.elements['jms-destination']&.text
    end
  end
end
