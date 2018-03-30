# frozen_string_literal: true
# position defaults to bottom - see resource definition for explanation of position
opennms_eventconf 'bogus-events.xml' do
  position 'top'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

# minimal
opennms_eventconf 'bogus-events2.xml'

# remotely sourced
opennms_eventconf 'apc.powernet.events.xml' do
  source 'https://raw.githubusercontent.com/opennms-config-modules/apc/master/events/apc.powernet.events.xml'
end

opennms_eventconf 'tripp-lite.events.xml' do
  source 'https://raw.githubusercontent.com/opennms-config-modules/tripp-lite/9da2da993a19efd237321491307b4b4fa515ac18/events/tripp-lite.events.xml'
  position 'top'
end

opennms_eventconf 'apache.httpd.syslog.events.xml' do
  source 'https://raw.githubusercontent.com/opennms-config-modules/apache/039f5011485f508ec49177883c8f36cceb4120f4/events/apache.httpd.syslog.events.xml'
  action [:create, :delete]
end
