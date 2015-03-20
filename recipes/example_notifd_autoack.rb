# example with all options
opennms_notifd_autoack "uei.opennms.org/example/exampleUp" do
  acknowledge "uei.opennms.org/example/exampleDown"
  resolution_prefix "RECTIFIED: "
  notify false
  matches ['nodeid','interfaceid','serviceid']
  notifies :run, 'opennms_send_event[restart_Notifd]'
end

# minimal options - will use 'nodeid' as the only match element
opennms_notifd_autoack "example2/exampleFixed" do
  acknowledge "example2/exampleBroken"
  notifies :run, 'opennms_send_event[restart_Notifd]'
end

# new autoack_alarm thing in 14
opennms_notifd_autoack_alarm "RESOLVED: " do
  notify true
  uei ['uei.opennms.org/test/one', 'uei.opennms.org/test/two']
  notifies :run, 'opennms_send_event[restart_Notifd]'
end
