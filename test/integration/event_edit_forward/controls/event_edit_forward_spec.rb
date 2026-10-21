# frozen_string_literal: true

control 'event_edit_forward' do
  describe 'OpenNMS Event Forward Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified forwarding rules' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'snmpudp'
      expect(eventconf.stdout).to include 'off'
    end
  end
end
