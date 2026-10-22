# frozen_string_literal: true

control 'event_noop' do
  title 'OpenNMS Event Noop Baseline Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(eventLabel))             { should eq 'Chef defined event: thresholdExceeded' }
    its(%w(descr))                  { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its(%w(logmsg content))         { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest))            { should eq 'logndisplay' }
    its(%w(logmsg notify))          { should be true }
    its(%w(severity))               { should eq 'Minor' }
    its(%w(operinstruct))           { should eq 'the operinstruct' }
    its(%w(autoaction))             { should eq([{ 'content' => 'someaction', 'state' => 'off' }]) }
    its(%w(varbindsdecode))         { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its(%w(tticket content))        { should eq 'tticketInfo' }
    its(%w(tticket state))          { should eq 'off' }
    its(%w(forward))                { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its(%w(script))                 { should eq([{ 'content' => 'anScript', 'language' => 'groovy' }]) }
    its(%w(mouseovertext))          { should eq 'mouseOverText' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType))    { should eq 1 }
    its(%w(alarmData autoClean))    { should be false }
  end
end
