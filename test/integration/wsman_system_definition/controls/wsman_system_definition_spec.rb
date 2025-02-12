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

  describe wsman_system_definition('Dell iDRAC 8') do
    it { should_not exist }
  end

  describe wsman_system_definition('create-if-missing') do
    it { should exist }
    its('rule') { should eq 'default' }
    its('file_name') { should eq 'wsman-datacollection.d/wsman-test-group.xml' }
    its('groups') { should eq %w(drac-power-delltest drac-power-test) }
  end
end
