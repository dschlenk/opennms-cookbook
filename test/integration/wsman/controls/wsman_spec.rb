# frozen_string_literal: true
control 'wsman_collection' do
  describe wsman_collection('foo') do
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
    its('include_system_definitions') { should eq nil } # we add empty <include_system_definitions/>
  end

  # minimal
  describe wsman_collection('bar') do
    it { should exist }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end
end

control 'wsman_collection_service' do
  describe wsman_collection_service('WS-ManFoo', 'foo', 'foo') do
    it { should exist }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 4445 }
    its('thresholding_enabled') { should eq true }
  end

  describe wsman_collection_service('WS-Man', 'default', 'example1') do
    it { should exist }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 3000 }
    its('retry_count') { should eq 1 }
    its('thresholding_enabled') { should eq false }
  end
end

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
end

control 'wsman_system_definition' do
  describe wsman_system_definition('wsman-test') do
    it { should exist }
    its('groups') { should include 'wsman-test-group' }
    its('groups') { should include 'wsman-another-group' }
    its('groups') { should include 'wsman-dell-group' }
    its('groups') { should include 'drac-power-delltest' }
  end
  describe wsman_system_definition('wsman-test') do
    it { should exist }
    its('groups') { should_not include 'drac-power-test' }
  end
end
