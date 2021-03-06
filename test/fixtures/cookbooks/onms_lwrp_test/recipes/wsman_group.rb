# frozen_string_literal: true
include_recipe 'onms_lwrp_test::wsman_collection_service'

opennms_resource_type 'wsman_thing' do
  group_name 'wsman-another-group'
  label 'wsman resource'
  resource_label '${resource}'
  notifies :restart, 'service[opennms]'
end

# add new group in new file bottom
opennms_wsman_group 'add wsman-another-group' do
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  group_name 'wsman-another-group'
  position 'bottom'
  resource_type 'wsman_thing'
  resource_uri 'http://schemas.test.group.com/'
  attribs [{ 'name' => 'Info', 'alias' => 'serviceTag', 'type' => 'string' }]
  notifies :restart, 'service[opennms]', :delayed
end

# add new group in new file top
opennms_wsman_group 'wsman-test-group' do
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  position 'top'
  resource_type 'node'
  resource_uri 'http://schemas.test.group.com/'
  attribs [{ 'name' => 'Info', 'alias' => 'serviceTag', 'type' => 'string' }, { 'name' => 'IdentifyingInfo', 'alias' => 'serviceTag', 'index-of' => '#IdentifyingDescriptions matches ".*ServiceTag"', 'type' => 'string' }]
  notifies :restart, 'service[opennms]', :delayed
end

# add new group in new file bottom
opennms_wsman_group 'wsman-dell-group' do
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  group_name 'wsman-dell-group'
  position 'bottom'
  resource_type 'dracPowerSupplyIndex'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/'
  dialect 'http://schemas.microsoft.com/wbem/wsman/'
  filter "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"
  attribs [{ 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }]
  notifies :restart, 'service[opennms]', :delayed
end

# add new group in new file top
opennms_wsman_group 'drac-power-delltest' do
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  group_name 'drac-power-delltest'
  position 'top'
  resource_type 'dracPowerSupplyIndex'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/'
  dialect 'http://schemas.microsoft.com/wbem/wsman/'
  filter "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"
  attribs [{ 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }]
  notifies :restart, 'service[opennms]', :delayed
end

# add new group to default file wsman-datacollection-config.xml on the bottom position
opennms_wsman_group 'drac-power-test' do
  group_name 'drac-power-test'
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  position 'bottom'
  resource_type 'dracPowerSupplyIndex'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/1/*'
  dialect 'http://schemas.microsoft.com/wbem/wsman/1/WQL'
  filter "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"
  attribs [{ 'name' => 'InputVoltage', 'alias' => 'inputVoltage', 'type' => 'Gauge' }, { 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }]
  notifies :restart, 'service[opennms]', :delayed
end

# add new group to default file wsman-datacollection-config.xml on the top position
opennms_wsman_group 'drac-power-test-bottom' do
  group_name 'drac-power-test-bottom'
  position 'top'
  resource_type 'dracPowerSupplyIndex'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/1/*'
  dialect 'http://schemas.microsoft.com/wbem/wsman/1/WQL'
  filter "select InputVoltage,InstanceID,PrimaryStatus,SerialNumber,TotalOutputPower from DCIM_PowerSupplyView where DetailedState != 'Absent'"
  attribs [{ 'name' => 'InputVoltage', 'alias' => 'inputVoltage', 'type' => 'Gauge' }, { 'name' => 'InstanceID', 'alias' => 'InstanceID', 'type' => 'String' }, { 'name' => 'PrimaryStatus', 'alias' => 'PrimaryStatus', 'type' => 'Gauge' }, { 'name' => 'SerialNumber', 'alias' => 'SerialNumber', 'type' => 'String' }, { 'name' => 'TotalOutputPower', 'alias' => 'TotalOutputPower', 'type' => 'Gauge' }]
  notifies :restart, 'service[opennms]', :delayed
end

# Existing group expect do nothing
opennms_wsman_group 'drac-system-board' do
  group_name 'drac-system-board'
  file_name 'wsman-datacollection.d/dell-idrac.xml'
  position 'top'
  resource_type 'node'
  resource_uri 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_NumericSensor'
  dialect 'http://schemas.microsoft.com/wbem/wsman/1/WQL'
  filter "select CurrentReading, ElementName from DCIM_NumericSensor WHERE ElementName LIKE 'System Board %'"
  attribs [{ 'name' => 'CurrentReading', 'filter' => "#ElementName == 'System Board MEM Usage'", 'alias' => 'sysBoardMemUsage', 'type' => 'Gauge' }, { 'name' => 'CurrentReading', 'filter' => "#ElementName == 'System Board IO Usage'", 'alias' => 'sysBoardMemUsage', 'type' => 'Gauge' }, { 'name' => 'CurrentReading', 'filter' => "#ElementName == 'System Board CPU Usage'", 'alias' => 'sysBoardMemUsage', 'type' => 'Gauge' }, { 'name' => 'CurrentReading', 'filter' => "#ElementName == 'System Board SYS Usage'", 'alias' => 'sysBoardMemUsage', 'type' => 'Gauge' }]
  notifies :restart, 'service[opennms]', :delayed
end

# Delete the group
opennms_wsman_group 'drac-power-test-bottom' do
  group_name 'drac-power-test-bottom'
  resource_uri 'http://schemas.dmtf.org/wbem/wscim/1/*'
  action :delete
end
