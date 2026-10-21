# frozen_string_literal: true

control 'event_remove_add_autoaction' do
  describe 'OpenNMS Event Remove Add Autoaction Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the added autoaction after removal' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'someaction'
      expect(eventconf.stdout).to include '"state":"off"'
    end
  end
end
