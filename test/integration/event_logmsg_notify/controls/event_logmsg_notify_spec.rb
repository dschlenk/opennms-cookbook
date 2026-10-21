# frozen_string_literal: true

control 'event_logmsg_notify' do
  describe 'OpenNMS Event Logmsg Notify Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the modified event logmsg notify setting' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include '"notify":false'
    end
  end
end
