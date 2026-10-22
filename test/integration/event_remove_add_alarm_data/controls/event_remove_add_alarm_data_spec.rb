# frozen_string_literal: true

control 'event_remove_add_alarm_data' do
  title 'OpenNMS Event Remove and Add Alarm Data Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType))    { should eq 1 }
    its(%w(alarmData autoClean))    { should be false }
  end
end
