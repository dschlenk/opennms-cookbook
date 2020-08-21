# frozen_string_literal: true
control 'wsman_group' do
  describe resource_type('wsman-thing', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'wsman resource' }
    its('resource_label') { should eq '${resource}' }
  end

  describe wsman_group('wsman-another-group', 'foo') do
    it { should exist }
    its('position') { should eq 'bottom' }
    its('group_name') { should eq 'wsman-another-group' }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' }, 'IdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('wsman-test-group', 'foo') do
    it { should exist }
    its('group_name') { should eq 'wsman-test-group' }
    its('position') { should eq 'top' }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' }, 'IdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('drac-power', 'foo') do
    it { should exist }
    its('group_name') { should eq 'drac-power' }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('position') { should eq 'top' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-delltest', 'foo') do
    it { should exist }
    its('group_name') { should eq 'drac-power-delltest' }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('position') { should eq 'top' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('filter') { should eq 'select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE "System Board %"' }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-test-bottom', 'foo') do
    it { should_not exist }
  end
end

