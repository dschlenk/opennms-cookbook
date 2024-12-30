# frozen_string_literal: true
control 'import_node_interface' do
  describe import_node_interface('10.0.0.1', 'dry-source', 'interfaceTestNodeID', 1242) do
    it { should exist }
    its('managed') { should be true }
    its('snmp_primary') { should eq 'P' }
  end

  describe import_node_interface('72.72.72.73', 'dry-source', 'interfaceTestNodeID', 1242) do
    it { should exist }
    its('managed') { should be true }
    its('snmp_primary') { should eq 'N' }
  end
end
