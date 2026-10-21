# frozen_string_literal: true

control 'event_remove_forward' do
  describe 'OpenNMS Event Remove Forward Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates that forward configurations have been removed' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).not_to include 'snmpudp'
      expect(eventconf.stdout).not_to include 'fwdInfo'
    end
  end
end
