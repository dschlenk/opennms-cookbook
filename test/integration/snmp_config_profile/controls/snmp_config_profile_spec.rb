describe snmp_config_profile('foo') do
  it { should exist }
  its('port') { should eq 171 }
  its('retry_count') { should eq 2 }
  its('timeout') { should eq 6000 }
  its('read_community') { should eq 'bar' }
  its('write_community') { should eq 'qux' }
  its('proxy_host') { should eq '127.0.0.1' }
  its('version') { should eq 'v2c' }
  its('max_vars_per_pdu') { should eq 30 }
  its('max_repetitions') { should eq 4 }
  its('max_request_size') { should eq 33001 }
  its('filter') { should eq "iphostname LIKE '%opennms%'" }
end

describe snmp_config_definition('profile_label' => 'foo') do
  it { should exist }
  its('ranges') { should eq ['10.1.1.2' => '10.1.1.3'] }
  its('specifics') { should eq ['10.1.1.4'] }
end

describe snmp_config_definition('profile_label' => 'foo', 'location' => 'bar') do
  it { should exist }
  its('ranges') { should eq ['10.3.1.2' => '10.3.1.3'] }
  its('specifics') { should eq ['10.3.1.4'] }
end
