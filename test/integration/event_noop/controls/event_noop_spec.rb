# frozen_string_literal: true

control 'event_noop' do
  title 'OpenNMS Event Noop Baseline Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_noop', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')             { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                  { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')         { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')            { should eq 'logndisplay' }
    its('logmsg.notify')          { should be true }
    its('severity')               { should eq 'Minor' }
    its('operinstruct')           { should eq 'the operinstruct' }
    its('tticket.info')           { should eq 'tticketInfo' }
    its('tticket.state')          { should eq 'off' }
    its('mouseovertext')          { should eq 'mouseOverText' }
    its('alarmData.reductionKey') { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')    { should eq 1 }
    its('alarmData.autoClean')    { should be false }

    it 'contains the exact nested parameter collection elements' do
      expect(subject.event_data['autoaction']).to include(hash_including('action' => 'someaction', 'state' => 'off'))
      expect(subject.event_data['forward']).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject.event_data['script']).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
    end
  end
end
