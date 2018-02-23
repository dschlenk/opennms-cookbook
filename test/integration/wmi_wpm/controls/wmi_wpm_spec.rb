# frozen_string_literal: true
control 'wmi_wpm' do
  describe resource_type('wmi_thing', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'wmi resource' }
    its('resource_label') { should eq '${resource}' }
  end

  describe wmi_wpm('wmi_test_resource', 'foo') do
    it { should exist }
    its('if_type') { should eq 'all' }
    its('recheck_interval') { should eq 7_200_000 }
    its('resource_type') { should eq 'wmi_thing' }
    its('keyvalue') { should eq 'Thing' }
    its('wmi_class') { should eq 'Win32_PerfFormattedData_PerfOS_Resource' }
    its('wmi_namespace') { should eq 'root/cimv2' }
    its('attribs') { should eq 'resource' => { 'alias' => 'resource', 'type' => 'string' }, 'metric' => { 'alias' => 'metric', 'type' => 'gauge' } }
  end
end
