# frozen_string_literal: true

control 'event_remove_add_alarm_data' do
  title 'OpenNMS Event Remove and Add Alarm Data Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(%w[alarmData reductionKey]) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w[alarmData alarmType]) { should eq 1 }
    its(%w[alarmData autoClean]) { should be false }
  end
end
