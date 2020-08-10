# frozen_string_literal: true
control 'wsman_system_definition' do
  describe opennms_wsman_system_definition('Dell iDRAC (All Version)') do
    it { should exist }
    its('groups') { should include 'drac-system' }
    its('groups') { should include 'drac-power-supply' }
  end
  describe opennms_wsman_system_definition('Dell iDRAC 8') do
    it { should exist }
    its('groups') { should_not include 'drac-system' }
    its('groups') { should_not include 'drac-power-supply' }
  end
end