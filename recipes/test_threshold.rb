# need to turn on thresholding on ICMP service first
opennms_poller_service "ICMP" do
  package_name 'example1'
  params 'rrd-repository' => '/opt/opennms/share/rrd/response', 'rrd-base-name' => 'icmp', 'ds-name' => 'icmp', 'thresholding-enabled' => 'true'
  status 'on'
  timeout 3000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
end

opennms_threshd_package "cheftest" do
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.16.1']
  include_ranges [{'begin' => '172.17.13.1', 'end' => '172.17.13.254'}, {'begin' => '172.17.20.1', 'end' => '172.17.20.254'}]
  exclude_ranges [{'begin' => '10.0.0.1', 'end' => '10.254.254.254'}]
  include_urls ['file:/opt/opennms/etc/include']
  services [{'name' => 'ICMP', 'interval' => 300000, 'status' => 'on', 'params' => {'thresholding-group' => 'cheftest'}}]
end

opennms_threshold_group "cheftest" do
  rrd_repository '/opt/opennms/share/rrd/response'
end

# common options
opennms_threshold "icmp" do
  group 'cheftest'
  type 'high'
  description 'ping latency too high'
  ds_type 'if'
  value 20000.0
  rearm 18000.0
  trigger 2
end

# common options
opennms_expression "icmp / 1000" do
  group 'cheftest'
  type 'high'
  description 'ping latency too high expression'
  ds_type 'if'
  value 20.0
  rearm 18.0
  trigger 3
end
