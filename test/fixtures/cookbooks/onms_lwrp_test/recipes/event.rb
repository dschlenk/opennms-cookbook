opennms_event "uei.opennms.org/cheftest/thresholdExceeded" do
  file "events/chef.events.xml"
  event_label "Chef defined event: thresholdExceeded"
  descr "<p>A threshold defined by a chef recipe has been exceeded.</p>"
  logmsg "A threshold has been exceeded."
  logmsg_dest "logndisplay"
  logmsg_notify true
  severity "Minor"
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  # tell Eventd to reload config
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

opennms_event "initial thresholdExceeded2" do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  file "events/chef.events.xml"
  event_label "Chef defined event: thresholdExceeded"
  descr "<p>A threshold defined by a chef recipe has been exceeded.</p>"
  logmsg "A threshold has been exceeded."
  logmsg_dest "logndisplay"
  logmsg_notify true
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  severity "Minor"
  operinstruct 'the operinstruct'
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString'}]}]
  tticket 'info' => 'tticketInfo', 'state' => 'off'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'}]
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  mouseovertext 'mouseOverText'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# test update event_label
opennms_event 'change event-label on thresholdExceeded2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  file "events/chef.events.xml"
  event_label "Chef definedd event: thresholdExceeded"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# test update descr
opennms_event 'change descr of thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  descr "<p>A thresholds defined by a chef recipe has been exceeded.</p>"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# test update logmsg
opennms_event 'change logmsg of thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  logmsg "A thresholds has been exceeded."
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test update logmsg_notify
opennms_event 'change logmsg notify attr of thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  logmsg_notify false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test update logmsg_dest
opennms_event 'change dest of logmsg of thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  logmsg_dest "discardtraps"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test remove mask
opennms_event 'remove mask in thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  mask []
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test add mask
opennms_event 'add mask back to thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test edit mask
opennms_event 'change the mask of thresholdExceeded2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['13'] }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test update severity
opennms_event 'change severity of TE2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  severity "Warning"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test remove alarm_data
opennms_event 'remove alarm_data of TE2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  alarm_data false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test add alarm_data
opennms_event 'add alarm-data back to TE2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# test edit alarm_data
opennms_event 'change alarm-data of TE2' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids', 'alarm_type' => 2, 'auto_clean' => false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit operinstruct' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  operinstruct 'the operinstructed'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'remove autoaction' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  notifies :run, 'opennms_send_event[restart_Eventd]'
  autoaction []
end
opennms_event 'add autoaction back' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  autoaction [{ 'action' => 'someaction', 'state' => 'off' }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit autoaction' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  autoaction [{ 'action' => 'someaction2', 'state' => 'on' }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'remove varbindsdecode' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  varbindsdecode []
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'add varbindsdecode back' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString'}]}]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit varbindsdecode' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  varbindsdecode [{ 'parmid' => 'theParmIds', 'decode' => [{'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString'}]}]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit tticket' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  tticket 'info' => 'tticketInfo', 'state' => 'on'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'remove tticket' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  tticket false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'put tticket back' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  tticket 'info' => 'tticketInfo', 'state' => 'on'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'remove forward' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  forward []
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'add forward back' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'}]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit forward ' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp'}]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'remove script' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  script []
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'put script back' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  script [{ 'name' => 'anScript', 'language' => 'groovy' }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit script' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  script [{ 'name' => 'anScript', 'language' => 'beanshell' }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'edit mouseovertext' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  mouseovertext 'mouseOverTexted'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event 'no changes' do
  uei "uei.opennms.org/cheftest/thresholdExceeded2"
  file "events/chef.events.xml"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

opennms_event 'uei.opennms.org/anUeiForANewThingInANewFile' do
  file "events/chef2.events.xml"
  event_label "Chef defined event: thresholdExceeded"
  descr "<p>A threshold defined by a chef recipe has been exceeded.</p>"
  logmsg "A threshold has been exceeded."
  logmsg_dest "logndisplay"
  logmsg_notify true
  severity "Minor"
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  # tell Eventd to reload config
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
