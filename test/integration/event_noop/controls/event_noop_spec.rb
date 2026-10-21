# frozen_string_literal: true

control 'event_noop' do
  describe 'OpenNMS Event Noop Configuration' do
    let(:eventconf) { fetch_live_eventconf('chef.events') }

    it 'successfully validates the full event noop configuration' do
      expect(eventconf.exit_status).to eq 0
      expect(eventconf.stdout).to include 'uei.opennms.org/cheftest/thresholdExceeded2'
      expect(eventconf.stdout).to include 'Chef defined event: thresholdExceeded'
      expect(eventconf.stdout).to include '<p>A threshold defined by a chef recipe has been exceeded.</p>'
      expect(eventconf.stdout).to include 'A threshold has been exceeded.'
      expect(eventconf.stdout).to include 'logndisplay'
      expect(eventconf.stdout).to include '"notify":true'
      expect(eventconf.stdout).to include 'Minor'
      expect(eventconf.stdout).to include 'the operinstruct'
      expect(eventconf.stdout).to include 'someaction'
      expect(eventconf.stdout).to include '"state":"off"'
      expect(eventconf.stdout).to include 'theParmId'
      expect(eventconf.stdout).to include 'theVarBindValue'
      expect(eventconf.stdout).to include 'theVarBindDecodedString'
      expect(eventconf.stdout).to include 'tticketInfo'
      expect(eventconf.stdout).to include 'fwdInfo'
      expect(eventconf.stdout).to include 'snmptcp'
      expect(eventconf.stdout).to include 'anScript'
      expect(eventconf.stdout).to include 'groovy'
      expect(eventconf.stdout).to include 'mouseOverText'
      expect(eventconf.stdout).to include '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(eventconf.stdout).to include '"alarm-type":1'
      expect(eventconf.stdout).to include '"auto-clean":false'
    end
  end
end
