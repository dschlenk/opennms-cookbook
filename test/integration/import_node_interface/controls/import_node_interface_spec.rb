# frozen_string_literal: true
control 'import_node_interface' do
  describe import_node_interface('10.0.0.1', 'dry-source', 'interfaceTestNodeID', 1242) do
    it { should exist }
    its('managed') { should be true }
    its('snmp_primary') { should eq 'P' }
    its('categories') { should eq %w(Servers Test) }
    its('meta_data') { should eq([{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]) }
  end

  describe import_node_interface('72.72.72.73', 'dry-source', 'interfaceTestNodeID', 1242) do
    it { should exist }
    its('managed') { should be false }
    its('snmp_primary') { should eq 'N' }
    its('categories') { should eq %w(Servers Test) }
    its('meta_data') { should eq([{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]) }
  end
end
