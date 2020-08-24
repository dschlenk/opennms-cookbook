# frozen_string_literal: true
control 'wsman_group' do
   describe resource_type('wsman-thing', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'wsman resource' }
    its('resource_label') { should eq '${resource}' }
  end

  describe wsman_group('wsman-another-group') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' }, 'IdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('wsman-test-group') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' }, 'IdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('drac-power') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-delltest') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq 'select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE "System Board %"' }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-test-bottom') do
    it { should_not exist }
  end
end

