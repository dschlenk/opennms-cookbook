# frozen_string_literal: true

control 'event_noop' do
  title 'OpenNMS Event Noop Baseline Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_noop', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')   { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')        { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('severity')     { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('mouseovertext') { should eq 'mouseOverText' }

    it 'validates nested hash properties correctly' do
      logmsg_hash = subject['logmsg'] || {}
      expect(logmsg_hash['content']).to eq 'A threshold has been exceeded.'
      expect(logmsg_hash['dest']).to eq 'logndisplay'
      expect([true, false, 'true', 'false', '', nil]).to include(logmsg_hash['notify'])

      tticket_hash = subject['tticket'] || {}
      expect(tticket_hash['info']).to eq 'tticketInfo'
      expect(tticket_hash['state']).to eq 'off'
      alarm_hash = subject['alarmData'] || {}
      expect(alarm_hash['reduction-key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(alarm_hash['alarm-type']).to eq 1
      expect(alarm_hash['auto-clean']).to eq false
    end

    it 'contains the exact nested parameter collection elements' do
      raw_autoaction = subject['autoaction']
      expect(raw_autoaction.is_a?(Hash) ? [raw_autoaction] : raw_autoaction).to include(hash_including('action' => 'someaction', 'state' => 'off'))

      raw_forward = subject['forward']
      expect(raw_forward.is_a?(Hash) ? [raw_forward] : raw_forward).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))

      raw_script = subject['script']
      expect(raw_script.is_a?(Hash) ? [raw_script] : raw_script).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))

      raw_decode = subject['varbindsdecode']
      expect(raw_decode.is_a?(Hash) ? [raw_decode] : raw_decode).to include(hash_including('parmid' => 'theParmId'))
    end
  end
end
