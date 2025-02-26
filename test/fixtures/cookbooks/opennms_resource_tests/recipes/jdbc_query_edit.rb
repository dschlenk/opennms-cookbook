include_recipe 'opennms_resource_tests::jdbc_query'
opennms_jdbc_query 'ifaceServicesQuery' do
  collection_name 'foo'
  if_type '106'
  recheck_interval 7_200_001
  resource_type 'interface'
  instance_column 'node_id'
  query_string 'select ip.nodeid as node_id,  count(if.serviceid) as service_count from ifservices if left join ipinterface ip on if.ipinterfaceid = ip.id group by ip.nodeid;'
  columns 'node_id' => { 'alias' => 'node_id', 'type' => 'string' }, 'service_count' => { 'alias' => 'service_count', 'type' => 'gauge' }
end
