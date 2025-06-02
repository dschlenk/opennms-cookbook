# frozen_string_literal: true
control 'import_node' do
  describe import_node('nodeA_ID', 'dry-source', 1241) do
    it { should exist }
    its('node_label') { should eq 'nodeA' }
  end

  describe import_node('nodeC', 'dry-source', 1241) do
    it { should exist }
    its('node_label') { should eq 'nodeC' }
    its('parent_foreign_source') { should eq 'dry-source' }
    its('parent_node_label') { should eq 'nodeB' }
    its('city') { should eq 'Tulsa' }
    its('building') { should eq 'Barn' }
    its('categories') { should eq %w(Servers Test) }
    its('assets') { should eq('vendorPhone' => '511', 'serialNumber' => 'SN12838932') }
    its('meta_data') { should eq([{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]) }
  end
end
