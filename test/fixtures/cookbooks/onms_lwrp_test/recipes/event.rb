# frozen_string_literal: true
opennms_event 'uei.opennms.org/cheftest/thresholdExceeded' do
  file 'events/chef.events.xml'
  event_label 'Chef defined event: thresholdExceeded'
  descr '<p>A threshold defined by a chef recipe has been exceeded.</p>'
  logmsg 'A threshold has been exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  # tell Eventd to reload config
  notifies :run, 'opennms_send_event[restart_Eventd]'
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# test delete
opennms_event 'uei.opennms.org/anUeiForANewThingInANewFile' do
  file 'events/chef2.events.xml'
  action :delete
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

#Test position top and eventconf_position top
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
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
