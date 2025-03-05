include_recipe 'opennms_resource_tests::threshold_common'
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
  services [{ 'name' => 'ICMP', 'interval' => 300_000, 'status' => 'on', 'params' => [{ 'thresholding-group' => 'cheftest' }] }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
end

opennms_threshold_group 'cheftest' do
  rrd_repository '/opt/opennms/share/rrd/response'
end

# most options
opennms_expression 'icmp / 1000' do
  group 'cheftest'
  type 'high'
  description 'ping latency too high expression'
  ds_type 'if'
  value 20.0
  rearm 18.0
  trigger 3
  triggered_uei 'uei.opennms.org/thresholdTest/testThresholdExceeded'
  rearmed_uei 'uei.opennms.org/thresholdTest/testThresholdRearmed'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
  notifies :run, 'opennms_send_event[restart_Thresholds]'
end
