# position defaults to bottom - see resource definition for explanation of position
opennms_eventconf 'bogus-events.xml' do
  position 'override'
end

# minimal
opennms_eventconf 'bogus-events2.xml'

# `position` 'top'; test `source_properties` on `cookbook_file`
opennms_eventconf 'bogus-events3.xml' do
  position 'top'
  source_properties(
    mode: '0777'
  )
end

# remotely sourced
opennms_eventconf 'apc.powernet.events.xml' do
  source_type 'remote_file'
  source 'https://raw.githubusercontent.com/opennms-config-modules/apc/master/events/apc.powernet.events.xml'
  source_properties(
    show_progress: true,
    mode: '0777'
  )
end

# template with default derived source value
opennms_eventconf 'NOTIFICATION-TEST-MIB.events.xml' do
  source_type 'template'
  variables(
    severity: 'Major'
  )
end

# use non-default `source` and illustrate that `source_properties` takes precendent
opennms_eventconf 'printer.events.xml' do
  source_type 'template'
  source 'Printer-MIB.events.xml.erb'
  variables(
    severity: 'Major'
  )
  source_properties(
    variables: { severity: 'Minor' }
  )
end

opennms_eventconf 'tripp-lite.events.xml' do
  source_type 'remote_file'
  source 'https://raw.githubusercontent.com/opennms-config-modules/tripp-lite/9da2da993a19efd237321491307b4b4fa515ac18/events/tripp-lite.events.xml'
  position 'top'
end

opennms_eventconf 'apache.httpd.syslog.events.xml' do
  source_type 'remote_file'
  source 'https://raw.githubusercontent.com/opennms-config-modules/apache/039f5011485f508ec49177883c8f36cceb4120f4/events/apache.httpd.syslog.events.xml'
  action [:create, :delete]
end

opennms_eventconf 'create-if-missing-event.xml' do
  position 'override'
  action :create_if_missing
end

opennms_eventconf 'noop-create-if-missing-event.xml' do
  position 'override'
  action :noop_create_if_missing
end
