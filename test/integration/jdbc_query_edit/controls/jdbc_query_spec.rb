control 'jdbc_query_edit' do
  describe jdbc_query('ifaceServicesQuery', 'foo') do
    it { should exist }
    its('if_type') { should eq '106' }
    its('recheck_interval') { should eq 7_200_001 }
    its('resource_type') { should eq 'interface' }
    its('instance_column') { should eq 'node_id' }
    its('query_string') { should eq 'select ip.nodeid as node_id,  count(if.serviceid) as service_count from ifservices if left join ipinterface ip on if.ipinterfaceid = ip.id group by ip.nodeid;' }
    its('columns') { should eq 'node_id' => { 'alias' => 'node_id', 'type' => 'string' }, 'service_count' => { 'alias' => 'service_count', 'type' => 'gauge' } }
  end
end
