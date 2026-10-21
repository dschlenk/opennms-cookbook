# frozen_string_literal: true

control 'event_remove_add_varbindsdecode' do
  describe 'OpenNMS Event Remove Add Varbindsdecode Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the added varbindsdecode after removal' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'theParmId'
      expect(eventconf.stdout).to include 'theVarBindValue'
      expect(eventconf.stdout).to include 'theVarBindDecodedString'
    end
  end
end
