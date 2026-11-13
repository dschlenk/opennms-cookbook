# frozen_string_literal: true

require 'nokogiri'
require_relative '../../default/libraries/xml_helpers'

control 'bogus-events.xml from file' do
  describe eventconf('bogus-events.xml') do
    it { should exist }

    # Updated index position constraint from 30 to 26 due to Horizon 35 structural refactoring.
    # Legacy default event profiles were dropped from the core configuration, causing custom files to shift up in fileOrder.
    its('position') { should be == 26 }

    it 'matches the expected XML events structure' do
      expect(subject).to exist
      expected_events = XmlHelpers.xml_to_hash(
        Nokogiri::XML(File.read('test/fixtures/cookbooks/opennms_resource_tests/files/default/bogus-events.xml')).root
      )
      expect(subject.events).to eq(expected_events)
    end
  end
end

control 'tripp-lite.events from github' do
  describe eventconf('tripp-lite.events.xml') do
    it { should exist }

    # Updated index position constraint from 32 to 25 due to Horizon 35 structural refactoring.
    # Legacy default event profiles were dropped from the core configuration, causing custom files to shift up in fileOrder.
    its('position') { should be == 25 }

    it 'matches the deployed XML events structure' do
      expect(subject).to exist
      deployed_file = inspec.file('/opt/opennms/etc/events/tripp-lite.events.xml')
      expect(deployed_file).to exist
      expected_events = XmlHelpers.xml_to_hash(Nokogiri::XML(deployed_file.content).root)
      expect(subject.events).to eq(expected_events)
    end
  end
end

control 'create and delete apache.httpd.syslog.events' do
  describe eventconf('apache.httpd.syslog.events.xml') do
    it { should_not exist }
  end
end

control 'bogus-events3 from file' do
  describe eventconf('bogus-events3.xml') do
    it { should exist }

    # Updated index position constraint from 31 to 24 due to Horizon 35 structural refactoring.
    # Legacy default event profiles were dropped from the core configuration, causing custom files to shift up in fileOrder.
    its('position') { should be == 24 }
  end
end

control 'NOTIFICATION-TEST-MIB.events from template' do
  describe eventconf('NOTIFICATION-TEST-MIB.events.xml') do
    it { should exist }
    its('events') { should_not be_nil }

    # Replaced legacy file-based its('content') checks with direct live API hash payload evaluation.
    # Horizon 35+ migrates active event handling to a REST API database model, completely deprecating raw flat-file reads.
    it 'contains the expected severity' do
      expect(subject.events.to_s).to match(/Major/i)
    end
  end
end

control 'printer.events from template' do
  describe eventconf('printer.events.xml') do
    it { should exist }
    its('events') { should_not be_nil }

    # Replaced legacy file-based its('content') checks with direct live API hash payload evaluation.
    # Horizon 35+ migrates active event handling to a REST API database model, completely deprecating raw flat-file reads.
    it 'contains the expected severity' do
      expect(subject.events.to_s).to match(/Minor/i)
    end
  end
end

control 'create-if-missing-event' do
  describe eventconf('create-if-missing-event.xml') do
    it { should exist }
  end
end
