# frozen_string_literal: true
control 'wsman_group' do
  describe wsman_group('wsman-thing', 'wsman-datacollection-config.xml') do
    it { should exist }
    its('position') { should eq 'bottom' }
    its('group_name') { should eq 'wsman-thing' }
    its('attribs') { should eq 'OtherIdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' } }
  end

  describe wsman_group('drac-system', 'drac-system') do
    it { should exist }
    its('group_name') { should eq 'drac-system' }
    its('file ') { should eq 'drac-system' }
    its('resource_type') { should eq 'node' }
    its('position') { should eq 'bottom' }
    its('resource_uri') { should eq 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_ComputerSystem' }
    its('attribs') { should eq 'OtherIdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string'  } }
  end

  describe wsman_group('drac-power-supply', 'drac-system') do
    it { should exist }
    its('group_name') { should eq 'drac-power-supply' }
    its('file ') { should eq 'drac-system' }
    its('resource_type') { should eq 'dracPowerSupplyIndex' }
    its('position') { should eq 'top' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('resource_uri') { should eq 'http://schemas.dmtf.org/wbem/wscim/1/*' }
    its('filter') { should eq 'select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != "Absent"' }
    its('attribs') { should eq 'InputVoltage' => { 'alias' => 'inputVoltage',  'type' => 'Gauge' }, 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge'  } }
  end

  describe wsman_group('drac-system-board', 'drac-system') do
    it { should exist }
    its('group_name') { should eq 'drac-system-board' }
    its('file ') { should eq 'drac-system' }
    its('resource_type') { should eq 'node' }
    its('position') { should eq 'top' }
    its('dialect') { should eq 'http://schemas.microsoft.com/wbem/wsman/1/WQL' }
    its('resource_uri') { should eq 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NumericSensor' }
    its('filter') { should eq 'select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE "System Board %"' }
    its('attribs') { should eq 'CurrentReading' => {'filter' => '#ElementName == "System Board MEM Usage"',  'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board IO Usage"',  'alias' => 'sysBoardIoUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board CPU Usage"',  'alias' => 'sysBoardCpuUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board SYS Usage"',  'alias' => 'sysBoardSysUsage',  'type' => 'Gauge' } }
  end
end

