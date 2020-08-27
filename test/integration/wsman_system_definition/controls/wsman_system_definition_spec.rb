# frozen_string_literal: true
control 'wsman_system_definition' do
  describe opennms_wsman_system_definition('wsman-test') do
    it { should exist }
    its('groups') { should include 'drac-power' }
    its('groups') { should include 'wsman-test-group' }
    its('groups') { should include 'wsman-another-group' }
    its('groups') { should include 'drac-power-delltest' }
    its('groups') { should include 'drac-power-test' }
  end
  describe opennms_wsman_system_definition('wsman-test') do
    it { should exist }
    its('groups') { should_not include 'drac-power-test' }
  end
end