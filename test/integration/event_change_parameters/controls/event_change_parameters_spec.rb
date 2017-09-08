# frozen_string_literal: true
control 'event_change_parameters' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('parameters') { should eq([{ 'name' => 'param1', 'value' => 'value1' }, { 'name' => 'param2', 'value' => 'value2', 'expand' => false }]) }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket') { should eq({'info' => 'tticketInfo', 'state' => 'off'}) }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext') { should eq 'mouseOverText' }
    its('alarm_data') { should eq({ 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false }) }
    its('position') { should eq 2 }
  end
end
