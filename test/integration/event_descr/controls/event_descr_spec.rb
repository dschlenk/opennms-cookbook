# frozen_string_literal: true

control 'event_descr' do
  describe 'OpenNMS Event Description Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the event description' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include '<p>A thresholds defined by a chef recipe has been exceeded.</p>'
    end
  end
end
