# frozen_string_literal: true
control 'import_node_interface_service' do
  describe import_node_interface_service('ICMP', '72.72.72.74', 'dry-source', 'svcNodeId') do
    it { should exist }
    its('categories') { should eq %w(Servers Test) }
    its('meta_data') { should eq([{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]) }
  end

  describe import_node_interface_service('TCP', '72.72.72.74', 'dry-source', 'svcNodeId') do
    it { should exist }
    its('categories') { should eq %w(Servers Test) }
    its('meta_data') { should eq([{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]) }
  end

  describe import_node_interface_service('UDP', '72.72.72.74', 'dry-source', 'svcNodeId') do
    it { should_not exist }
  end
end
