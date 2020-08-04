# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
include_recipe 'onms_lwrp_test::wsman_collection'
opennms_resource_type 'wsman_thing' do
  group_name 'wsman_static'
  label 'wsman resource'
  resource_label '${resource}'
  notifies :restart, 'service[opennms]'
end


opennms_wmi_wpm 'wsman_test_resource' do
  collection_name 'foo'
  if_type 'all'
  recheck_interval 7_200_000
  resource_type 'wsman_thing'
  keyvalue 'Thing'
  attribs 'resource' => { 'alias' => 'resource', 'type' => 'string' }, 'metric' => { 'alias' => 'metric', 'type' => 'gauge' }
  notifies :restart, 'service[opennms]', :delayed
end


opennms_wsman_group 'drac-system' do
  collection_name 'foo'
  if_type 'all'
  recheck_interval 7_200_000
  resource_type 'node'
  resource_uri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_ComputerSystem'
  attribs 'OtherIdentifyingInfo' => { 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' }
  notifies :restart, 'service[opennms]', :delayed
end


opennms_wsman_group 'drac-power-supply' do
  collection_name 'foo'
  if_type 'all'
  recheck_interval 7_200_000
  resource_type 'dracPowerSupplyIndex'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/1/*'
  dialect 'http://schemas.microsoft.com/wbem/wsman/1/WQL'
  filter "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"
  attribs 'InputVoltage' => { 'alias' => 'inputVoltage',  'type' => 'Gauge' }, 'InstanceID' => { 'alias' => 'InstanceID',  'type' => 'String' }, 'PrimaryStatus' => { 'alias' => 'PrimaryStatus',  'type' => 'Gauge' }, 'SerialNumber' => { 'alias' => 'SerialNumber',  'type' => 'String' }, 'TotalOutputPower' => { 'alias' => 'TotalOutputPower',  'type' => 'Gauge' }
  notifies :restart, 'service[opennms]', :delayed
end

opennms_wsman_group 'drac-system-board' do
  collection_name 'foo'
  if_type 'all'
  recheck_interval 7_200_000
  resource_type 'node'
  resource_uri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NumericSensor'
  dialect 'http://schemas.microsoft.com/wbem/wsman/1/WQL'
  filter "select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE 'System Board %'"
  attribs 'CurrentReading' => {'filter' => '#ElementName == "System Board MEM Usage"',  'alias' => 'sysBoardMemUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board IO Usage"',  'alias' => 'sysBoardIoUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board CPU Usage"',  'alias' => 'sysBoardCpuUsage',  'type' => 'Gauge' }, 'CurrentReading' => {'filter' => '#ElementName == "System Board SYS Usage"',  'alias' => 'sysBoardSysUsage',  'type' => 'Gauge' }
  notifies :restart, 'service[opennms]', :delayed
end