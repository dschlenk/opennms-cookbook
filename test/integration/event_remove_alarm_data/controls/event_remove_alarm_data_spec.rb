# frozen_string_literal: true

control 'event_remove_alarm_data' do
  describe 'OpenNMS Event Remove Alarm Data Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates that alarm data has been removed' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).not_to include 'alarm-type'
      expect(eventconf.stdout).not_to include 'reduction-key'
    end
  end
end
