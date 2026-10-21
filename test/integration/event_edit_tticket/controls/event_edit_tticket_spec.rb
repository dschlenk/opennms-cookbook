# frozen_string_literal: true

control 'event_edit_tticket' do
  describe 'OpenNMS Event Trouble Ticket Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified trouble ticket configuration' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'tticketInfo'
      expect(eventconf.stdout).to include '"state":"on"'
    end
  end
end
