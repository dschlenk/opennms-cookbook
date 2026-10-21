# frozen_string_literal: true

control 'event_edit_mouseovertext' do
  describe 'OpenNMS Event Mouseovertext Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified mouseovertext rules' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'mouseOverTexted'
    end
  end
end
