# frozen_string_literal: true

control 'event_remove_alarm_data' do
  title 'OpenNMS Event Remove Alarm Data Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_alarm_data', 'events/chef.events.xml') do
    it { should exist }
    its('alarmData') { should be_nil }
  end
end
