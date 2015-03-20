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
