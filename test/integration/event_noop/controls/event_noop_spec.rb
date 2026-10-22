# frozen_string_literal: true

control 'event_noop' do
  title 'OpenNMS Event Noop Baseline Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')             { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                  { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg.content')         { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')            { should eq 'logndisplay' }
    its('logmsg.notify')          { should be true }
    its('severity')               { should eq 'Minor' }
    its('operinstruct')           { should eq 'the operinstruct' }
    its('autoaction')             { should eq([{ 'content' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode')         { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket.content')        { should eq 'tticketInfo' }
    its('tticket.state')          { should eq 'off' }
    its('forward')                { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script')                 { should eq([{ 'content' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext')          { should eq 'mouseOverText' }
    its('alarmData.reductionKey') { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')    { should eq 1 }
    its('alarmData.autoClean')    { should be false }
  end
end
