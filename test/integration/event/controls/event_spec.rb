control 'event' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded', 'events/chef.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('position') { should eq 2 }
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
    its('position') { should eq 3 }
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
    its('position') { should eq 1 }
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
    its('position') { should eq 4 }
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
    its('position') { should eq 5 }
  end

  describe event('uei.opennms.org/anUeiForANewThingInANewFile', 'events/chef2.events.xml') do
    it { should_not exist }
  end

  describe event('uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop', 'events/chef3.events.xml') do
    it { should exist }
    its('position') { should eq 1 }
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
    its('position') { should be == 25 }
  end

  describe eventconf('chef4.events.xml') do
    it { should exist }
    its('position') { should be == 26 }
  end

  describe event('uei.opennms.org/fillerForANewThingInANewFile1', 'events/chef4.events.xml') do
    it { should exist }
    its('position') { should eq 2 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe event('uei.opennms.org/fillerForANewThingInANewFile2', 'events/chef4.events.xml') do
    it { should exist }
    its('position') { should eq 3 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe event('uei.opennms.org/eventTopFileTop', 'events/chef4.events.xml') do
    it { should exist }
    its('position') { should eq 1 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe event('uei.opennms.org/eventBottomFileTop', 'events/chef4.events.xml') do
    it { should exist }
    its('position') { should eq 4 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq('reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false) }
  end

  describe event('uei.opennms.org/collectionGroupTest', 'events/chef5.events.xml') do
    it { should exist }
    its('position') { should eq 1 }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>collection group test.</p>' }
    its('logmsg') { should eq 'A collection group test.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Indeterminate' }
    its('collection_group') { should eq [{ 'name' => 'nodeGroup', 'resource_type' => 'nodeSnmp', 'instance' => 'instanceParmName', 'collections' => [ { 'name' => 'TIME', 'type' => 'counter', 'param_values' => { 'primary' => 1, 'secondary' => 2 } }], 'rrd' => { 'rra' => [ 'RRA:AVERAGE:0.5:1:8928' ], 'step' => 60, 'heartbeat' => 120 } }] }
  end

  describe event('uei.opennms.org/parametersTest', 'events/chef6.events.xml') do
    it { should exist }
    its('position') { should eq 2 }
    its('event_label') { should eq 'Chef defined event: parametersTest' }
    its('descr') { should eq '<p>parameters.</p>' }
    its('logmsg') { should eq 'parameters test.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Critical' }
    its('parameters') { should eq [{ 'name' => 'paramName', 'value' => 'someString', 'expand' => true }] }
  end

  describe event('uei.opennms.org/operactionTest', 'events/chef6.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: operactionTest' }
    its('descr') { should eq '<p>operactionTest.</p>' }
    its('logmsg') { should eq 'operactionTest test.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Warning' }
    its('position') { should eq 1 }
    its('operaction') { should eq [{ 'action' => 'string', 'state' => 'off', 'menutext' => 'help me' }] }
  end

  describe event('uei.opennms.org/autoackTest', 'events/chef6.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: autoackTest' }
    its('descr') { should eq '<p>autoackTest.</p>' }
    its('logmsg') { should eq 'autoackTest test.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Minor' }
    its('position') { should eq 3 }
    its('autoacknowledge') { should eq 'info' => 'please do not wake me up when the computer breaks', 'state' => 'off' }
  end

  describe event('uei.opennms.org/filters', 'events/chef6.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: filters' }
    its('descr') { should eq '<p>filters.</p>' }
    its('logmsg') { should eq 'filters test.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Major' }
    its('position') { should eq 4 }
    its('event_filters') { should eq [{ 'eventparm' => 'one', 'pattern' => '/^one&two{;t|hree😇$/', 'replacement' => '💩' }] }
  end
  describe event('events/chef.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: createifmissing' }
    its('descr') { should eq '<p>Trying to create a file if its missing.</p>' }
    its('logmsg') { should eq 'creating file if its missing.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Minor' }
  end
end
