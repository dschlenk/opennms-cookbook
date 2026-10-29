# frozen_string_literal: true

control 'event_remove_add_alarm_data' do
  title 'OpenNMS Event Remove and Add Alarm Data Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_alarm_data', 'events/chef.events.xml') do
    it { should exist }
    its('alarmData.reductionKey') { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')    { should eq 1 }
    its('alarmData.autoClean')    { should be false }
  end
end
