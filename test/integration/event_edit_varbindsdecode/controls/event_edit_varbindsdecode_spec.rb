# frozen_string_literal: true

control 'event_edit_varbindsdecode' do
  describe 'OpenNMS Event Varbindsdecode Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates modified varbindsdecode configuration' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'theParmIds'
      expect(eventconf.stdout).to include 'theVarBindValue'
      expect(eventconf.stdout).to include 'theVarBindDecodedString'
    end
  end
end
