# frozen_string_literal: true

control 'event_remove_add_script' do
  describe 'OpenNMS Event Remove Add Script Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the added script after removal' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'anScript'
      expect(eventconf.stdout).to include 'groovy'
    end
  end
end
