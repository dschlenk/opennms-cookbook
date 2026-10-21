# frozen_string_literal: true

control 'event_add_parameters' do
  describe 'OpenNMS Live Event Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'retrieves configuration parameters successfully' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'param1'
      expect(eventconf.stdout).to include 'paramValue1'
      expect(eventconf.stdout).to include 'param2'
      expect(eventconf.stdout).to include 'paramValue2'
      expect(eventconf.stdout).to include '"expand":true'
    end
  end
end
