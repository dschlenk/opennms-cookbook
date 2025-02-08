# frozen_string_literal: true
control 'wsman_group' do
  describe wsman_group('wsman-another-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'wsman_thing' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq [{ 'name' => 'Info', 'alias' => 'serviceTag', 'type' => 'string' }] }
  end

  describe wsman_group('wsman-test-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.test.group.com/' }
    its('attribs') { should eq [{ 'name' => 'Info', 'alias' => 'serviceTag', 'type' => 'string' }, { 'name' => 'IdentifyingInfo', 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' }] }
  end

  describe wsman_group('wsman-dell-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq [{ 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }] }
  end

  describe wsman_group('drac-power-delltest', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq [{ 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }] }
  end

  describe wsman_group('drac-power-test', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/1/*' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq [{ 'name' => 'InputVoltage', 'alias' => 'inputVoltage', 'type' => 'Gauge' }, { 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }] }
  end

  describe wsman_group('drac-system-board', 'wsman-datacollection.d/dell-idrac.xml') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NumericSensor' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq "select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE 'System Board %'" }
  end

  describe wsman_group('drac-power-test-bottom', 'default') do
    it { should_not exist }
  end

  describe wsman_group('create-if-missing', 'wsman-datacollection.d/wsman-test-group.xm') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/1/*' }
  end

  describe wsman_group('noop-create-if-missing', 'wsman-datacollection.d/wsman-test-group.xm') do
    it { should_not exist }
  end
end
