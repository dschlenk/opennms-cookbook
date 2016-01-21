# position defaults to bottom - see resource definition for explanation of position
opennms_eventconf "bogus-events.xml" do 
  position 'top'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# minimal
opennms_eventconf "bogus-events2.xml"
