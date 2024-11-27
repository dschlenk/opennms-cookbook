# frozen_string_literal: true
# need to turn on thresholding on ICMP service first
opennms_poller_service 'ICMP' do
  package_name 'example1'
  parameters 'rrd-repository' => { 'value' => '/opt/opennms/share/rrd/response' }, 'rrd-base-name' => { 'value' => 'icmp' }, 'ds-name' => { 'value' => 'icmp' }, 'thresholding-enabled' => { 'value' => 'true' }
  status 'on'
  timeout 3000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
  notifies :restart, 'service[opennms]'
end

opennms_threshd_package 'cheftest' do
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.16.1']
  include_ranges [{ 'begin' => '172.17.13.1', 'end' => '172.17.13.254' }, { 'begin' => '172.17.20.1', 'end' => '172.17.20.254' }]
  exclude_ranges [{ 'begin' => '10.0.0.1', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include']
  services [{ 'name' => 'ICMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest' } }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
end

opennms_threshold_group 'cheftest' do
  rrd_repository '/opt/opennms/share/rrd/response'
end

# define events for triggered/rearmed
opennms_event 'uei.opennms.org/thresholdTest/testThresholdExceeded' do
  file 'events/chef-threshold.events.xml'
  event_label 'Chef defined event: testThresholdExceeded'
  descr '<p>A threshold defined by a chef recipe that tests thresholds has been exceeded.</p>'
  logmsg 'Chef test threshold exceeded.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Minor'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

opennms_event 'uei.opennms.org/thresholdTest/testThresholdRearmed' do
  file 'events/chef-threshold.events.xml'
  event_label 'Chef defined event: testThresholdRearmed'
  descr '<p>A threshold defined by a chef recipe that tests thresholds has been rearmed.</p>'
  logmsg 'Chef test threshold rearmed.'
  logmsg_dest 'logndisplay'
  logmsg_notify true
  severity 'Normal'
  notifies :run, 'opennms_send_event[restart_Eventd]'
end

opennms_threshold_group 'mib2' do
  rrd_repository '/var/opennms/rrd/snmp'
end

opennms_threshold_group 'hrstorage' do
  action :delete
end
