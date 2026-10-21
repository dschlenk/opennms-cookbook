# frozen_string_literal: true

control 'event_edit_operinstruct' do
  describe 'OpenNMS Event Operator Instructions Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified operator instructions' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'the operinstructed'
    end
  end
end
