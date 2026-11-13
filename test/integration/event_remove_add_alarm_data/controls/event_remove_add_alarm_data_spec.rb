# frozen_string_literal: true

control 'event_remove_add_alarm_data' do
  title 'OpenNMS Event Remove and Add Alarm Data Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_alarm_data', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the alarmData hash properties correctly' do
      alarm_hash = subject['alarmData'] || {}
      expect(alarm_hash['reduction-key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(alarm_hash['alarm-type']).to eq 1
      expect(alarm_hash['auto-clean']).to eq false
    end
  end
end
