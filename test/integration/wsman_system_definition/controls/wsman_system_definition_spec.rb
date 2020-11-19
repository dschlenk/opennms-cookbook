# frozen_string_literal: true
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
