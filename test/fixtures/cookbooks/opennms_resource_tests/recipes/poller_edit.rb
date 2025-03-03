include_recipe 'opennms_resource_tests::poller'

# change filter and add everything else
opennms_poller_package 'bar' do
  filter "IPADDR == '10.0.0.1'"
  specifics ['10.0.0.1']
  include_ranges ['begin' => '10.0.0.1', 'end' => '10.0.0.1']
  exclude_ranges ['begin' => '10.0.2.1', 'end' => '10.0.2.254']
  include_urls ['file:/opt/opennms/etc/bar']
  rrd_step 601
  remote false
  outage_calendars ['ignore localhost on tuesdays']
  rras ['RRA:AVERAGE:0.5:2:4033', 'RRA:AVERAGE:0.5:24:2977', 'RRA:AVERAGE:0.5:576:733', 'RRA:MAX:0.5:576:733', 'RRA:MIN:0.5:576:733']
end

# change just the filter
opennms_poller_package 'foo' do
  filter "(IPADDR != '0.0.0.0')"
end

# you're allowed to change anything except service name / package name
# note that the following must be specified in update resources if not default to remain as is:
# * interval
# * user_defined
# * status

# lets try changing everything
opennms_poller_service 'SNMP' do
  package_name 'foo'
  interval 700_000
  user_defined false
  status 'on'
  timeout 5001
  port 162
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

# change just the class on this one
opennms_poller_service 'SNMPBar' do
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

# add params and specify things that get rendered as params
opennms_poller_service 'add params to SNMPBar2' do
  service_name 'SNMPBar2'
  package_name 'bar'
  timeout 5002
  port 165
  parameters 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.1' }
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

opennms_poller_service 'change interval ICMPBar' do
  service_name 'ICMPBar'
  package_name 'bar'
  interval 600_001
  user_defined true
  status 'off'
  timeout 5000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'change user_defined ICMPBar2' do
  service_name 'ICMPBar2'
  package_name 'bar'
  user_defined false
  interval 600_000
  status 'off'
  timeout 5000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'change status ICMPBar3' do
  service_name 'ICMPBar3'
  package_name 'bar'
  user_defined true
  interval 600_000
  status 'on'
  timeout 5000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'change timeout ICMPBar4' do
  service_name 'ICMPBar4'
  package_name 'bar'
  user_defined true
  interval 600_000
  status 'off'
  timeout 5005
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'change params ICMPBar5' do
  service_name 'ICMPBar5'
  package_name 'bar'
  user_defined true
  interval 600_000
  status 'off'
  timeout 5000
  parameters 'packet-size' => { 'value' => '32' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'change class ICMPBar6' do
  service_name 'ICMPBar6'
  package_name 'bar'
  user_defined true
  interval 600_000
  status 'off'
  timeout 5000
  parameters 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.2' }
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end
