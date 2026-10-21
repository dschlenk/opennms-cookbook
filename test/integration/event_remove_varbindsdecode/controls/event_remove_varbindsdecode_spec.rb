# frozen_string_literal: true

control 'event_remove_varbindsdecode' do
  describe 'OpenNMS Event Remove Varbindsdecode Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates that varbindsdecode configurations have been removed' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).not_to include 'theParmId'
      expect(eventconf.stdout).not_to include 'theVarBindValue'
    end
  end
end
