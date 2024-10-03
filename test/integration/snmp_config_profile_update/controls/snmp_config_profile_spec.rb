# the last resource in the run list with the same identity (in the case of snmp_config_profile, the label/name) wins
describe snmp_config_profile('foo') do
  it { should exist }
  its('port') { should eq 161 }
  its('retry_count') { should eq 2 }
  its('timeout') { should eq 7000 }
  its('read_community') { should eq 'bear' }
  its('write_community') { should eq 'quux' }
  its('proxy_host') { should eq '127.0.0.2' }
  its('version') { should eq 'v1' }
  its('max_vars_per_pdu') { should eq nil }
  its('max_repetitions') { should eq nil }
  its('max_request_size') { should eq nil }
  its('filter') { should eq nil }
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
