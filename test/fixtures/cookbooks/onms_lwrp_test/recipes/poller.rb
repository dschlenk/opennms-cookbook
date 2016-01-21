# most useful options
opennms_poller_package "foo" do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'foo')"
  specifics ['10.0.0.1']
  include_ranges 'begin' => '10.0.1.1', 'end' => '10.0.1.254'
  exclude_ranges 'begin' => '10.0.2.1', 'end' => '10.0.2.254'
  include_urls ['file:/opt/opennms/etc/foo']
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976','RRA:AVERAGE:0.5:576:732','RRA:MAX:0.5:576:732','RRA:MIN:0.5:576:732']
  notifies :restart, "service[opennms]", :delayed
end

# at least one service must be defined for each package
opennms_poller_service "SNMP" do
  package_name "foo"
  interval 600000
  user_defined true
  status "off"
  timeout 5000
  port 161
  params 'oid' => '.1.3.6.1.2.1.1.2.0'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

# minimal
opennms_poller_package "bar" do
  filter "IPADDR != '0.0.0.0'"
  notifies :restart, "service[opennms]", :delayed
end

# at least one service must be defined for each package
opennms_poller_service "SNMPBar" do
  package_name "bar"
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end
