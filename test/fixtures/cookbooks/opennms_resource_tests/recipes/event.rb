opennms_event 'uei.opennms.org/cheftest/thresholdExceeded' do
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  position 'top'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
end

opennms_event 'initial thresholdExceeded2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  severity 'Minor'
  operinstruct 'the operinstruct'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
  tticket 'info' => 'tticketInfo', 'state' => 'off'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  mouseovertext 'mouseOverText'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
end

# new event at the top of an existing file
opennms_event 'new event at the top' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded3'
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded3'
  descr '<p>A threshold defined by a chef recipe has been exceeded3.</p>'
  logmsg 'A threshold has been exceeded3.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  severity 'Minor'
  operinstruct 'the operinstruct'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
  tticket 'info' => 'tticketInfo', 'state' => 'off'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  mouseovertext 'mouseOverText'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  position 'top'
end

opennms_event 'new event at the bottom of existing file' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded4'
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded4'
  descr '<p>A threshold defined by a chef recipe has been exceeded4.</p>'
  logmsg 'A threshold has been exceeded4.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  severity 'Minor'
  operinstruct 'the operinstruct'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
  tticket 'info' => 'tticketInfo', 'state' => 'off'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  mouseovertext 'mouseOverText'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  position 'bottom'
end

# new event with complex mask
opennms_event 'new event with diverse mask' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded5'
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded5'
  descr '<p>A threshold defined by a chef recipe has been exceeded4.</p>'
  logmsg 'A threshold has been exceeded4.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }, { 'vbnumber' => '1', 'vbvalue' => %w(1 2 3) }]
  severity 'Minor'
  operinstruct 'the operinstruct'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
  tticket 'info' => 'tticketInfo', 'state' => 'off'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  mouseovertext 'mouseOverText'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
end

# new event in new file
opennms_event 'uei.opennms.org/anUeiForANewThingInANewFile' do
  file 'events/chef2.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
end

# test delete
opennms_event 'uei.opennms.org/anUeiForANewThingInANewFile' do
  file 'events/chef2.events.xml'
  action :delete
end

# Test position top and eventconf_position top
opennms_event 'uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop' do
  file 'events/chef3.events.xml'
  position 'top'
  eventconf_position 'top'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
end

# Test position top and eventconf_position bottom
# this one should be index 2
opennms_event 'uei.opennms.org/fillerForANewThingInANewFile1' do
  file 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  eventconf_position 'top'
end

# this one should be index 3
opennms_event 'uei.opennms.org/fillerForANewThingInANewFile2' do
  file 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  eventconf_position 'top'
end

# this one should be index 1
opennms_event 'uei.opennms.org/eventTopFileTop' do
  file 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  position 'top'
  eventconf_position 'top'
end

# this one should be index 4
opennms_event 'uei.opennms.org/eventBottomFileTop' do
  file 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  position 'bottom'
  eventconf_position 'top'
end

opennms_event 'uei.opennms.org/collectionGroupTest' do
  file 'events/chef5.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>collection group test.</p>'
  logmsg 'A collection group test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Indeterminate'
  position 'bottom'
  eventconf_position 'top'
  collection_group [
    {
      'name' => 'nodeGroup',
      'resource_type' => 'nodeSnmp',
      'instance' => 'instanceParmName',
      'collections' => [ { 'name' => 'TIME', 'type' => 'counter', 'param_values' => { 'primary' => 1, 'secondary' => 2 } }],
      'rrd' => {
        'rra' => [ 'RRA:AVERAGE:0.5:1:8928' ],
        'step' => 60, 'heartbeat' => 120
      }
    }
  ]
end

opennms_event 'uei.opennms.org/parametersTest' do
  file 'events/chef6.events.xml'
  event_label 'Chef defined event: parametersTest'
  descr '<p>parameters.</p>'
  logmsg 'parameters test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Critical'
  position 'bottom'
  eventconf_position 'top'
  parameters [{ 'name' => 'paramName', 'value' => 'someString', 'expand' => true }]
end

opennms_event 'uei.opennms.org/operactionTest' do
  file 'events/chef6.events.xml'
  event_label 'Chef defined event: operactionTest'
  descr '<p>operactionTest.</p>'
  logmsg 'operactionTest test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Warning'
  position 'top'
  eventconf_position 'override'
  operaction [{ 'action' => 'string', 'state' => 'off', 'menutext' => 'help me' }]
end

opennms_event 'uei.opennms.org/autoackTest' do
  file 'events/chef6.events.xml'
  event_label 'Chef defined event: autoackTest'
  descr '<p>autoackTest.</p>'
  logmsg 'autoackTest test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  position 'bottom'
  eventconf_position 'override'
  autoacknowledge 'info' => 'please do not wake me up when the computer breaks', 'state' => 'off'
end

opennms_event 'uei.opennms.org/filters' do
  file 'events/chef6.events.xml'
  event_label 'Chef defined event: filters'
  descr '<p>filters.</p>'
  logmsg 'filters test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Major'
  position 'bottom'
  eventconf_position 'bottom'
  filters [{ 'eventparm' => 'one', 'pattern' => '/^one&two{;t|hree😇$/', 'replacement' => '💩' }]
end
