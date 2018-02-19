# frozen_string_literal: true
control 'reparent_imported_node' do
  describe import_node('nodeC', 'dry-source') do
    it { should exist }
    its('node_label') { should eq 'node-c.example.net' }
    its('parent_foreign_source') { should eq 'dry-source' }
    its('parent_node_label') { should eq 'nodeA' }
    its('parent_foreign_id') { should eq 'nodeA_ID' }
    its('city') { should eq 'Tulsa' }
    its('building') { should eq 'Barn' }
    its('categories') { should eq %w(Servers Test) }
    its('assets') { should eq('vendorPhone' => '511', 'serialNumber' => 'SN12838932') }
  end
end
