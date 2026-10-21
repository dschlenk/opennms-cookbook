# frozen_string_literal: true

control 'event_change_parameters' do
  describe 'OpenNMS Event Parameters Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified event parameters' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'param1'
      expect(eventconf.stdout).to include 'value1'
      expect(eventconf.stdout).to include 'param2'
      expect(eventconf.stdout).to include 'value2'
      expect(eventconf.stdout).to include '"expand":false'
    end
  end
end
