# frozen_string_literal: true

control 'event_edit_alarm_data' do
  title 'OpenNMS Event Alarm Data Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_alarm_data', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the updated alarm-data configurations' do
      # Handles any key notation alignment emitted by the parser engine
      alarm_data = subject['alarm-data'] || subject['alarm_data'] || subject['alarmData']

      expect(alarm_data).not_to be_nil

      reduction_key = alarm_data['reduction-key'] || alarm_data['reduction_key'] || alarm_data['reductionKey']
      alarm_type    = alarm_data['alarm-type']    || alarm_data['alarm_type']    || alarm_data['alarmType']
      auto_clean    = if alarm_data.key?('auto-clean')
                        alarm_data['auto-clean']
                      elsif alarm_data.key?('auto_clean')
                        alarm_data['auto_clean']
                      else
                        alarm_data['autoClean']
                      end

      # Validates the edited values, NOT the baseline values
      expect(reduction_key).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids'
      expect(alarm_type.to_i).to eq 2
      expect(auto_clean.to_s).to eq 'false'
    end
  end
end
