# frozen_string_literal: true

control 'event_label' do
  describe 'OpenNMS Event Label Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the modified event label' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'Chef definedd event: thresholdExceeded'
    end
  end
end
