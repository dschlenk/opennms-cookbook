# frozen_string_literal: true

control 'event_remove_add_alarm_data' do
  describe 'OpenNMS Event Remove Add Alarm Data Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the added alarm data after removal' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(eventconf.stdout).to include '"alarm-type":1'
      expect(eventconf.stdout).to include '"auto-clean":false'
    end
  end
end
