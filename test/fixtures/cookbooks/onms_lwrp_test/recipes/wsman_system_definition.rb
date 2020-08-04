# frozen_string_literal: true
opennms_wsman_system_definition 'Dell iDRAC (All Version)' do
  groups ['drac-system', 'drac-power-supply']
  action :add
end
opennms_wsman_system_definition 'Dell iDRAC 8' do
  groups ['drac-system-board']
  action :remove
end
