include_recipe 'opennms_resource_tests::wsman_group'
opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  rule "#productVendor matches '^.*'"
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  groups %w(wsman-dell-group wsman-test-group wsman-another-group)
  action :create
end

opennms_wsman_system_definition 'same-wsman-test' do
  name 'wsman-test'
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  groups %w(drac-power-delltest drac-power-test)
  action :add
end

opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  groups ['drac-power-test']
  action :remove
end
