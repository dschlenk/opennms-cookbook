# frozen_string_literal: true

control 'event_edit_alarm_data' do
  title 'OpenNMS Event Alarm Data Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_alarm_data', 'events/chef.events.xml') do
    it { should exist }
    its('alarmData.reductionKey') { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids' }
    its('alarmData.alarmType')    { should eq 2 }
    its('alarmData.autoClean')    { should be false }
  end
end
