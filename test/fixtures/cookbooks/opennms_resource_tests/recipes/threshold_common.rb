# frozen_string_literal: true

# need to turn on thresholding on ICMP service first
opennms_poller_service 'ICMP' do
  package_name 'example1'
  parameters 'rrd-repository' => { 'value' => '/opt/opennms/share/rrd/response' }, 'rrd-base-name' => { 'value' => 'icmp' }, 'ds-name' => { 'value' => 'icmp' }, 'thresholding-enabled' => { 'value' => 'true' }, 'timeout' => { 'value' => '3000' }
  status 'on'
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
  notifies :restart, 'service[opennms]'
end

opennms_threshd_package 'cheftest' do
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.16.1']
  include_ranges [{ 'begin' => '172.17.13.1', 'end' => '172.17.13.254' }, { 'begin' => '172.17.20.1', 'end' => '172.17.20.254' }]
  exclude_ranges [{ 'begin' => '10.0.0.1', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include']
  services [{ 'name' => 'ICMP', 'interval' => 300_000, 'status' => 'on', 'params' => [{ 'thresholding-group' => 'cheftest' }] }]
end

opennms_threshold_group 'cheftest' do
  rrd_repository '/opt/opennms/share/rrd/response'
end

#=====================================================================
# THRESHOLD EVENTS CONFIGURATIONS (DATABASE BULK LAYOUT ALIGNMENT)
#=====================================================================

opennms_event 'uei.opennms.org/thresholdTest/testThresholdExceeded' do
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: testThresholdExceeded'
  descr '<p>A threshold defined by a chef recipe that tests thresholds has been exceeded.</p>'
  logmsg 'Chef test threshold exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [
         { 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] },
         { 'mename' => 'generic', 'mevalue' => ['6'] },
         { 'mename' => 'specific', 'mevalue' => ['2'] },
       ]
  severity 'Minor'
  eventconf_position 'bottom'
end

opennms_event 'uei.opennms.org/thresholdTest/testThresholdRearmed' do
  source_name 'events/chef.events.xml'
  event_label 'Chef defined event: testThresholdRearmed'
  descr '<p>A threshold defined by a chef recipe that tests thresholds has been rearmed.</p>'
  logmsg 'Chef test threshold rearmed.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  mask [
         { 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] },
         { 'mename' => 'generic', 'mevalue' => ['6'] },
         { 'mename' => 'specific', 'mevalue' => ['2'] },
       ]
  severity 'Normal'
  eventconf_position 'bottom'
end

#=====================================================================
# THRESHOLD GROUPS MUTATIONS
#=====================================================================

opennms_threshold_group 'mib2' do
  rrd_repository '/var/opennms/rrd/snmp'
end

opennms_threshold_group 'hrstorage' do
  action :delete
end

opennms_threshold_group 'create-if-missing' do
  action :create_if_missing
end

opennms_threshold_group 'noop-create-if-missing' do
  group_name 'create-if-missing'
  rrd_repository '/var/opennms/rrd/snmps'
  action :create_if_missing
end
