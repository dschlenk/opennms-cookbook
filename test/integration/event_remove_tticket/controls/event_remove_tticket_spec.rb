# frozen_string_literal: true

control 'event_remove_tticket' do
  describe 'OpenNMS Event Remove Trouble Ticket Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates that the trouble ticket has been removed' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).not_to include 'uei.opennms.org/cheftest/thresholdExceeded2'
    end
  end
end
