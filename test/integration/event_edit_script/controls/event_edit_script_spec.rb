# frozen_string_literal: true

control 'event_edit_script' do
  describe 'OpenNMS Event Script Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified script rules' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'anScript'
    end
  end
end
