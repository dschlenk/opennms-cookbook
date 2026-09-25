require 'nokogiri'
require_relative '../../default/libraries/xml_helpers'
control 'bogus-events.xml from file' do
  describe eventconf('bogus-events.xml') do
    it { should exist }
    # 20+ is position 3
    its('position') { should be == 0 }
    its('events') { should eq XmlHelpers.xml_to_hash(Nokogiri::XML(File.read('test/fixtures/cookbooks/opennms_resource_tests/files/default/bogus-events.xml')).root) }
  end
end

control 'tripp-lite.events from github' do
  describe eventconf('tripp-lite.events.xml') do
    it { should exist }
    its('position') { should be <= 27 }
    its('events') { should eq XmlHelpers.xml_to_hash(Nokogiri::XML(inspec.http('https://raw.githubusercontent.com/opennms-config-modules/tripp-lite/9da2da993a19efd237321491307b4b4fa515ac18/events/tripp-lite.events.xml').body).root) }
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
    its('position') { should be == 2 }
  end
end

control 'NOTIFICATION-TEST-MIB.events from template' do
  describe eventconf('NOTIFICATION-TEST-MIB.events.xml') do
    it { should exist }
    its('content') { should match %r{<severity>Major</severity>} }
  end
end

control 'printer.events from template' do
  describe eventconf('printer.events.xml') do
    it { should exist }
    its('content') { should match %r{<severity>Minor</severity>} }
  end
end

control 'create-if-missing-event' do
  describe eventconf('create-if-missing-event.xml') do
    it { should exist }
  end
end
