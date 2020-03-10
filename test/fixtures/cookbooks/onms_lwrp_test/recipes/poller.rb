# frozen_string_literal: true
include_recipe 'onms_lwrp_test::poll_outage'
# most useful options
opennms_poller_package 'foo' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'foo')"
  specifics ['10.0.0.1']
  include_ranges ['begin' => '10.0.1.1', 'end' => '10.0.1.254']
  exclude_ranges ['begin' => '10.0.2.1', 'end' => '10.0.2.254']
  include_urls ['file:/opt/opennms/etc/foo']
  rrd_step 600
  remote true
  outage_calendars ['ignore localhost on mondays']
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  notifies :restart, 'service[opennms]', :delayed
end

# at least one service must be defined for each package
opennms_poller_service 'SNMP' do
  package_name 'foo'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  port 161
  parameters 'oid' => '.1.3.6.1.2.1.1.2.0'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

# minimal
opennms_poller_package 'bar' do
  filter "IPADDR != '0.0.0.0'"
  notifies :restart, 'service[opennms]', :delayed
end

# at least one service must be defined for each package
opennms_poller_service 'SNMPBar' do
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

# create things to edit and delete later
opennms_poller_service 'create SNMPBar2' do
  service_name 'SNMPBar2'
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

opennms_poller_service 'create ICMPBar' do
  service_name 'ICMPBar'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar2' do
  service_name 'ICMPBar2'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar3' do
  service_name 'ICMPBar3'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar4' do
  service_name 'ICMPBar4'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar5' do
  service_name 'ICMPBar5'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar6' do
  service_name 'ICMPBar6'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar7' do
  service_name 'ICMPBar7'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  timeout 5000
  parameters 'packet-size' => '65', 'retry' => '3'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end
