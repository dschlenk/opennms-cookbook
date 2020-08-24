# frozen_string_literal: true
control 'wsman_group' do
  describe wsman_group('wsman-another-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' } }
  end

  describe wsman_group('wsman-test-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq 'Info' => { 'alias' => 'serviceTag', 'type' => 'string' }, 'IdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('drac-power-test', 'wsman-datacollection-config.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/1/*' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InputVoltage'=>{'alias' => 'inputVoltage',  'type' => 'Gauge'}, 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end


  describe wsman_group('drac-power', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-delltest', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' }}
  end

  describe wsman_group('drac-power-test-bottom', 'default') do
    it { should_not exist }
  end
end


