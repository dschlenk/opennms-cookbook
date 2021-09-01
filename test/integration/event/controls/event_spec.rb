# frozen_string_literal: true
control 'event' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded', 'events/chef.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('position') { should eq 1 }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket') { should eq('info' => 'tticketInfo', 'state' => 'off') }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext') { should eq 'mouseOverText' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
    its('position') { should eq 2 }
  end

  describe event('uei.opennms.org/cheftest/thresholdExceeded3', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded3' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded3.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded3.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket') { should eq('info' => 'tticketInfo', 'state' => 'off') }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext') { should eq 'mouseOverText' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
    its('position') { should eq 0 }
  end

  describe event('uei.opennms.org/cheftest/thresholdExceeded4', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded4' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded4.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded4.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket') { should eq('info' => 'tticketInfo', 'state' => 'off') }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext') { should eq 'mouseOverText' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
    its('position') { should eq 3 }
  end

  describe event('uei.opennms.org/cheftest/thresholdExceeded5', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }, { 'vbnumber' => '1', 'vbvalue' => %w(1 2 3) }]) do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded5' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded4.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded4.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct') { should eq 'the operinstruct' }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its('tticket') { should eq('info' => 'tticketInfo', 'state' => 'off') }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'groovy' }]) }
    its('mouseovertext') { should eq 'mouseOverText' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
    its('position') { should eq 4 }
  end

  describe event('uei.opennms.org/anUeiForANewThingInANewFile', 'events/chef2.events.xml') do
    it { should_not exist }
  end

  describe event('uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop', 'events/chef3.events.xml') do
    it { should exist }
    its('position') { should eq 0 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe eventconf('chef3.events.xml') do
    it { should exist }
    # 20+ is position 3
    its('position') { should be <= 3 }
  end
end

