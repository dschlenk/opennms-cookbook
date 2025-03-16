include_recipe 'opennms_resource_tests::poll_outage'
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
end

opennms_poller_package 'create_if_missing' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'create_if_missing')"
  package_name 'createifmissing'
  specifics ['10.0.0.1']
  include_ranges ['begin' => '10.0.1.1', 'end' => '10.0.1.254']
  exclude_ranges ['begin' => '10.0.2.1', 'end' => '10.0.2.254']
  rrd_step 600
  remote true
  outage_calendars ['ignore localhost on mondays']
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  action :create_if_missing
end

opennms_poller_service 'ICMP - createifmissing' do
  service_name 'ICMP'
  package_name 'createifmissing'
  interval 600_000
  user_defined true
  status 'off'
  parameters(
    'timeout' => { 'value' => '5000' }
  )
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_package 'noop_create_if_missing' do
  filter "(IPADDR != '0.0.0.0')"
  package_name 'createifmissing'
  specifics ['10.0.0.1']
  include_ranges ['begin' => '10.0.1.1', 'end' => '10.0.1.254']
  exclude_ranges ['begin' => '10.0.2.1', 'end' => '10.0.2.254']
  rrd_step 700
  remote true
  outage_calendars ['ignore localhost on mondays']
  rras ['RRA:AVERAGE:0.5:2:4033', 'RRA:AVERAGE:0.5:24:2977', 'RRA:AVERAGE:0.5:576:733', 'RRA:MAX:0.5:576:733', 'RRA:MIN:0.5:576:733']
  action :create_if_missing
end

# at least one service must be defined for each package
opennms_poller_service 'SNMP' do
  package_name 'foo'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.0' }, 'timeout' => { 'value' => '5000' }, 'port' => { 'value' => '161' }
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end
# minimal
opennms_poller_package 'bar' do
  filter "IPADDR != '0.0.0.0'"
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

opennms_poller_service "create 'SNMPBar 2'" do
  service_name 'SNMPBar 2'
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end

opennms_poller_service 'create ICMPBar' do
  service_name 'ICMPBar'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar2' do
  service_name 'ICMPBar2'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar3' do
  service_name 'ICMPBar3'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'extremely complex' do
  service_name 'Complex'
  package_name 'bar'
  pattern '^Device&<![CDATA[/>CDATAConfig-(?<configType>.+)$'
  parameters(
    'port' => { 'value' => '12' },
    'timeout' => { 'value' => '300' },
    'page-sequence' => {
      'configuration' => "<page attribute='value'><farameter>text<!-- comment  -->more text</farameter></page>",
    }
  )
  class_name 'org.opennms.netmgt.poller.monitors.PageSequenceMonitor'
  class_parameters(
    'key' => { 'value' => '400' },
    'other key' => {
      'configuration' => "<page attribute='value'><sarameter>text<!-- comment  -->more text</sarameter></page>",
    },
    'everything key' => {
      'configuration' => "<porg attribute='value'><qarameter>text<!-- comment  -->more text</qarameter></porg>",
    }
  )
end

opennms_poller_service 'create ICMPBar4' do
  service_name 'ICMPBar4'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar5' do
  service_name 'ICMPBar5'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar6' do
  service_name 'ICMPBar6'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_poller_service 'create ICMPBar7' do
  service_name 'ICMPBar7'
  package_name 'bar'
  interval 600_000
  user_defined true
  status 'off'
  parameters 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' }, 'timeout' => { 'value' => '5000' }
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end
