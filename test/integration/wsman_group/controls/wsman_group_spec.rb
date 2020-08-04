# frozen_string_literal: true
control 'wsman_group' do
  describe resource_type('wsman_thing', 'wsman_static') do
    it { should exist }
    its('label') { should eq 'wsman resource' }
    its('resource_label') { should eq '${resource}' }
  end

  describe wmi_wpm('wsman_test_resource', 'foo') do
    it { should exist }
    its('if_type') { should eq 'all' }
    its('recheck_interval') { should eq 7_200_000 }
    its('resource_type') { should eq 'wsman_thing' }
    its('keyvalue') { should eq 'Thing' }
    its('attribs') { should eq 'resource' => { 'alias' => 'resource', 'type' => 'string' }, 'metric' => { 'alias' => 'metric', 'type' => 'gauge' } }
  end
end
