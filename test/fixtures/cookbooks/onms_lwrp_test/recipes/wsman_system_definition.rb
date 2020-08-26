# frozen_string_literal: true
opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  groups ['drac-power', 'wsman-test-group', 'wsman-another-group', 'drac-power-delltest', 'drac-power-test', 'drac-power-test-bottom']
  action :add
end
opennms_wsman_system_definition 'wsman-test' do
  name 'wsman-test'
  groups ['drac-power-test-bottom']
  action :remove
end
