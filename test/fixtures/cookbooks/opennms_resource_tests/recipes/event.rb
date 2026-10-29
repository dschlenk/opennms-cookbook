# frozen_string_literal: true

opennms_event 'uei.opennms.org/cheftest/thresholdExceeded' do
  source_name 'events/chef.events.xml'
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
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-script'
  source_name 'events/chef.events.xml'
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

opennms_event 'new event at the top' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded3'
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded3'
  descr '<p>A threshold defined by a chef recipe has been exceeded3.</p>'
  logmsg 'A threshold has been exceeded3.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  position 'top'
end

opennms_event 'new event at the bottom of existing file' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded4-complex'
  source_name 'events/chef.events.xml'
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

opennms_event 'new event with diverse mask' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded5-arrays'
  source_name 'events/chef.events.xml'
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

opennms_event 'uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop-isolated' do
  source_name 'events/chef3.events.xml'
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

opennms_event 'uei.opennms.org/fillerForANewThingInANewFile1-isolated' do
  source_name 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  eventconf_position 'top'
end

opennms_event 'uei.opennms.org/fillerForANewThingInANewFile2-isolated' do
  source_name 'events/chef4.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  eventconf_position 'top'
end

opennms_event 'uei.opennms.org/eventTopFileTop-isolated' do
  source_name 'events/chef4.events.xml'
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

opennms_event 'uei.opennms.org/eventBottomFileTop-isolated' do
  source_name 'events/chef4.events.xml'
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

opennms_event 'uei.opennms.org/collectionGroupTest-isolated' do
  source_name 'events/chef5.events.xml'
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
                       },
                     },
                   ]
end

opennms_event 'uei.opennms.org/parametersTest-isolated' do
  source_name 'events/chef6.events.xml'
  event_label 'Chef defined event: parametersTest'
  descr 'parameters.'
  logmsg 'parameters test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Critical'
  position 'bottom'
  eventconf_position 'top'
  parameters [{ 'name' => 'paramName', 'value' => 'someString', 'expand' => true }]
end

opennms_event 'uei.opennms.org/operactionTest-isolated' do
  source_name 'events/chef6.events.xml'
  event_label 'Chef defined event: operactionTest'
  descr 'operactionTest.'
  logmsg 'operactionTest test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Warning'
  position 'top'
  eventconf_position 'override'
  operaction [{ 'action' => 'string', 'state' => 'off', 'menutext' => 'help me' }]
end

opennms_event 'uei.opennms.org/autoackTest-isolated' do
  source_name 'events/chef6.events.xml'
  event_label 'Chef defined event: autoackTest'
  descr 'autoackTest.'
  logmsg 'autoackTest test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  position 'bottom'
  eventconf_position 'override'
  autoacknowledge 'info' => 'please do not wake me up when the computer breaks', 'state' => 'off'
end

opennms_event 'uei.opennms.org/filters-isolated' do
  source_name 'events/chef6.events.xml'
  event_label 'Chef defined event: filters'
  descr 'filters.'
  logmsg 'filters test.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Major'
  position 'bottom'
  eventconf_position 'bottom'
  filters [{ 'eventparm' => 'one', 'pattern' => '^one_and_two_matching_pattern$', 'replacement' => 'MATCHED_AND_REPLACED' }]
end

opennms_event 'create_if_missing-isolated' do
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: createifmissing'
  descr 'Trying to create a file if its missing.'
  logmsg 'creating file if its missing.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  action :create_if_missing
end

opennms_event 'noop_create_if_missing-isolated' do
  uei 'create_if_missing-isolated'
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: noopcreateifmissing'
  descr 'Trying to create create if missing that does nothing.'
  logmsg 'creating create if missing that does nothing.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  action :create_if_missing
end
##############################################
# INITIAL BASELINE TEST
##############################################
opennms_event 'initial description baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_descr'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'This is the original baseline description text that will be updated.'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  severity 'Minor'
end

opennms_event 'initial alarm_data baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_alarm_data'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline description.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%', 'alarm_type' => 1, 'auto_clean' => true
end

opennms_event 'initial autoaction baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_autoaction'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline autoaction event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  autoaction [{ 'action' => 'originalaction', 'state' => 'off' }]
end

opennms_event 'initial forward baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_forward'
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline forward event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  forward [{ 'info' => 'oldFwdInfo', 'state' => 'on', 'mechanism' => 'snmpudp' }]
end

opennms_event 'initial mouseovertext baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_mouseovertext'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline mouseover event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  mouseovertext 'originalMouseOverText'
end

opennms_event 'initial operinstruct baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_operinstruct'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline operinstruct event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  operinstruct 'originalOperInstruct'
end

opennms_event 'initial script baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_script'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline script event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
end

opennms_event 'initial tticket baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_tticket'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline trouble ticket event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  tticket 'info' => 'oldTicketInfo', 'state' => 'off'
end

opennms_event 'initial varbindsdecode baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_varbindsdecode'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline varbindsdecode event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  varbindsdecode [{ 'parmid' => 'oldParmId', 'decode' => [{ 'varbindvalue' => 'oldValue', 'varbinddecodedstring' => 'oldString' }] }]
end

opennms_event 'initial event_label baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_label'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Old Event Label'
  descr 'Baseline event_label event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
end

opennms_event 'initial logmsg baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline event.'
  logmsg 'Original baseline log message.'
  logmsg_dest 'logndisplay'
  severity 'Minor'
end

opennms_event 'initial logmsg_dest baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_dest'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline logmsg destination event.'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  severity 'Minor'
end

opennms_event 'initial logmsg_notify baseline' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_notify'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline logmsg notify event.'
  logmsg 'A threshold has been exceeded.'
  logmsg_notify true
  severity 'Minor'
end

opennms_event 'initial rich baseline for noop' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_noop'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'A threshold defined by a chef recipe has been exceeded.'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
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

opennms_event 'initial baseline for remove_add_alarm_data' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_alarm_data'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline alarm data event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%', 'alarm_type' => 1, 'auto_clean' => true
end

opennms_event 'initial baseline for remove_add_autoaction' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_autoaction'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline autoaction event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  autoaction [{ 'action' => 'originalaction', 'state' => 'off' }]
end

opennms_event 'initial baseline for remove_add_forward' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_forward'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline forward mechanism event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  forward [{ 'info' => 'originalFwdInfo', 'state' => 'on', 'mechanism' => 'snmpudp' }]
end

opennms_event 'initial baseline for remove_add_script' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_script'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline script element event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  script [{ 'name' => 'oldScript', 'language' => 'beanshell' }]
end

opennms_event 'initial baseline for remove_add_tticket' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_tticket'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline tticket element event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  script [{ 'name' => 'oldScript', 'language' => 'beanshell' }]
end

opennms_event 'initial baseline for remove_add_varbindsdecode' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_varbindsdecode'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline varbindsdecode element event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  varbindsdecode [{ 'parmid' => 'oldParmId', 'decode' => [{ 'varbindvalue' => 'oldValue', 'varbinddecodedstring' => 'oldString' }] }]
end

opennms_event 'initial populated baseline for remove_alarm_data' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_alarm_data'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline alarm data cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%', 'alarm_type' => 1, 'auto_clean' => true
end

opennms_event 'initial populated baseline for remove_autoaction' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_autoaction'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline autoaction cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
end

opennms_event 'initial populated baseline for remove_forward' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_forward'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline forward mechanism cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]
end

opennms_event 'initial populated baseline for remove_script' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_script'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline script element cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
end

opennms_event 'initial populated baseline for remove_tticket' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_tticket'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline trouble ticket cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  tticket 'info' => 'tticketInfo', 'state' => 'on'
end

opennms_event 'initial populated baseline for remove_varbindsdecode' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_varbindsdecode'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline varbindsdecode cleanup event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
end

opennms_event 'initial baseline for event_severity' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_severity'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr 'Baseline severity event.'
  logmsg 'A threshold has been exceeded.'
  severity 'Minor'
end

[443, 8443].each do |port|
  [60, 30].each do |days|
    opennms_event "TLS-Cert-Expire-#{port}-#{days} - nodeLostService" do
      uei 'uei.opennms.org/nodes/nodeLostService'
      position 'top'
      source_name 'events/opennms.pollerd.events.xml'
      if days == 30
        mask [{ 'mename' => 'uei', 'mevalue' => ['uei.opennms.org/nodes/nodeLostService'] },
              { 'mename' => 'service', 'mevalue' => ["TLS-Cert-Expire-#{port}"] }]
      else
        mask [{ 'mename' => 'uei', 'mevalue' => ['uei.opennms.org/nodes/nodeLostService'] },
              { 'mename' => 'service', 'mevalue' => ["TLS-Cert-Expire-#{port}-#{days}"] }]
      end
      event_label 'OpenNMS-defined node event: nodeLostService'
      descr 'A %service% outage was identified on interface %interface% because of the following condition: %parm[eventReason]%. A new Outage record has been created and service level availability calculations will be impacted until this outage is resolved.'
      logmsg '%service% outage identified on interface %interface% with reason code: %parm[eventReason]%.'
      logmsg_dest 'logndisplay'
      if days <= 30
        severity 'Critical'
      elsif days == 60
        severity 'Major'
      else
        severity 'Minor'
      end
      alarm_data false
    end
  end
end