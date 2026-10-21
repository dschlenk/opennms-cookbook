# frozen_string_literal: true

control 'event_remove_autoaction' do
  describe 'OpenNMS Event Remove Autoaction Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates that autoaction rules have been removed' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).not_to include 'someaction'
    end
  end
end
