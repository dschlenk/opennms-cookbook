# frozen_string_literal: true

control 'event_edit_alarm_data' do
  title 'OpenNMS Event Alarm Data Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids' }
    its(%w(alarmData alarmType))    { should eq 2 }
    its(%w(alarmData autoClean))    { should be false }
    its(%w(position))               { should eq 2 }
  end
end
