# frozen_string_literal: true

control 'event_remove_alarm_data' do
  title 'OpenNMS Event Remove Alarm Data Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(alarmData)) { should be_nil }
  end
end
