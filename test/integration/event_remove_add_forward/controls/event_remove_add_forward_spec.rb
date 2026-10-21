# frozen_string_literal: true

control 'event_remove_add_forward' do
  describe 'OpenNMS Event Remove Add Forward Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the added forward after removal' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'fwdInfo'
      expect(eventconf.stdout).to include 'snmptcp'
      expect(eventconf.stdout).to include '"state":"off"'
    end
  end
end
