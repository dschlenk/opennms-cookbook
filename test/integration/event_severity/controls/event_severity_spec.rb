# frozen_string_literal: true

control 'event_severity' do
  describe 'OpenNMS Event Severity Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the modified event severity' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'Warning'
    end
  end
end
