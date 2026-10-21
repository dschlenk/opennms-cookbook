# frozen_string_literal: true

control 'event_logmsg' do
  describe 'OpenNMS Event Logmsg Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the modified event logmsg' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'A thresholds has been exceeded.'
    end
  end
end
