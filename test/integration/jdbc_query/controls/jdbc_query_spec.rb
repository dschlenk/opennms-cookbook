# frozen_string_literal: true
control 'jdbc_query' do
  describe jdbc_query('ifaceServicesQuery', 'foo') do
    it { should exist }
    its('if_type') { should eq 'ignore' }
    its('recheck_interval') { should eq 7_200_000 }
    its('resource_type') { should eq 'opennms_node' }
    its('instance_column') { should eq 'nodeid' }
    its('query_string') { should eq 'select ip.nodeid as nodeid,  count(if.serviceid) as service_count from ifservices if left join ipinterface ip on if.ipinterfaceid = ip.id group by ip.nodeid;' }
    its('columns') { should eq 'nodeid' => { 'alias' => 'nodeid', 'type' => 'string' }, 'service_count' => { 'alias' => 'service_count', 'type' => 'gauge' } }
  end
end
