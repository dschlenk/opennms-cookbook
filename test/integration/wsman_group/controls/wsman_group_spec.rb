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

  describe wsman_group('wsman-dell-group', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' }}
  end

  describe wsman_group('drac-power-delltest', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'" }
    its('attribs') { should eq 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' }}
  end

  describe wsman_group('drac-power-test', 'wsman-datacollection.d/wsman-test-group.xml') do
    it { should exist }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/1/*' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"}
    its('attribs') { should eq 'InputVoltage' => { 'alias' => 'inputVoltage',  'type' => 'Gauge' }, 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-system-board', 'wsman-datacollection.d/dell-idrac.xml') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_uri') { should eq 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NumericSensor' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('filter') { should eq "select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE 'System Board %'"}
    its('attribs') { should eq 'CurrentReading' => { 'filter' => "#ElementName == 'System Board MEM Usage'", 'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' }, 'CurrentReading' => { 'filter' => "#ElementName == 'System Board IO Usage'", 'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' }, 'CurrentReading' => { 'filter' => "#ElementName == 'System Board CPU Usage'", 'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' }, 'CurrentReading' => { 'filter' => "#ElementName == 'System Board SYS Usage'", 'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' } }
  end

  describe wsman_group('drac-power-test-bottom', 'default') do
    it { should_not exist }
  end
end


