# frozen_string_literal: true
opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  groups ['drac-power', 'wsman-test-group', 'wsman-another-group', 'drac-power-delltest', 'drac-power-test']
  action :add
end
opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  file_name 'wsman-datacollection.d/wsman-test-group.xml'
  groups ['drac-power-test']
  action :remove
end
