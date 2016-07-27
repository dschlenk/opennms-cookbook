opennms_resource_type "opennms_node" do
  group_name "metasyntactic"
  label "opennms node"
  resource_label "${nodeid}"
end

opennms_jdbc_query "ifaceServicesQuery" do
  collection_name "foo"
  if_type 'ignore'
  recheck_interval 7200000
  resource_type 'opennms_node'
  instance_column 'nodeid'
  query_string "select ip.nodeid as nodeid,  count(if.serviceid) as service_count from ifservices if left join ipinterface ip on if.ipinterfaceid = ip.id group by ip.nodeid;"
  columns 'nodeid' => { 'alias' => 'nodeid', 'type' => 'string' }, 'service_count' => {'alias' => 'service_count', 'type' => 'gauge'}
  notifies :restart, "service[opennms]", :delayed
end
