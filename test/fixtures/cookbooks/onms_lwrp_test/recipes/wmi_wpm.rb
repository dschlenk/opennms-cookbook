opennms_resource_type "wmi_thing" do
  group_name "metasyntactic"
  label "wmi resource"
  resource_label "${resource}"
  notifies :restart, 'service[opennms]'
end

opennms_wmi_wpm "wmi_test_resource" do
  collection_name "foo"
  if_type 'all'
  recheck_interval 7200000
  resource_type 'wmi_thing'
  keyvalue 'Thing'
  wmi_class "Win32_PerfFormattedData_PerfOS_Resource"
  wmi_namespace "root/cimv2"
  attribs 'resource' => { 'alias' => 'resource', 'type' => 'string' }, 'metric' => {'alias' => 'metric', 'type' => 'gauge'}
  notifies :restart, "service[opennms]", :delayed
end
