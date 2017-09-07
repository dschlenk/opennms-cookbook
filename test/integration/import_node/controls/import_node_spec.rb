# frozen_string_literal: true
control 'import_node' do
  describe import_node('nodeA_ID', 'dry-source') do
    it { should exist }
    its('node_label') { should eq 'nodeA' }
  end

  describe import_node('nodeC', 'dry-source') do
    it { should exist }
    its('node_label') { should eq 'nodeC' }
    its('parent_foreign_source') { should eq 'dry-source' }
    its('parent_node_label') { should eq 'nodeB' }
    its('city') { should eq 'Tulsa' }
    its('building') { should eq 'Barn' }
    its('categories') { should eq ['Servers', 'Test'] }
    its('assets') { should eq({ 'vendorPhone' => '511', 'serialNumber' => 'SN12838932' }) }
  end
end
