describe snmp_config_profile('foo') do
  it { should_not exist }
end

describe snmp_config_definition('profile_label' => 'foo') do
  it { should_not exist }
end

describe snmp_config_definition('profile_label' => 'foo', 'location' => 'bar') do
  it { should_not exist }
end
