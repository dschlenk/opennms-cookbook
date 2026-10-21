# frozen_string_literal: true

control 'event_edit_alarm_data' do
  describe 'OpenNMS Event Alarm Data Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified alarm data' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids'
      expect(eventconf.stdout).to include '"alarm-type":2'
    end
  end
end
