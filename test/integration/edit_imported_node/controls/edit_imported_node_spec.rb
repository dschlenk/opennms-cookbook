# frozen_string_literal: true
control 'edit_imported_node' do
  describe import_node('nodeC', 'dry-source') do
    it { should exist }
    its('city') { should eq 'Brooklyn' }
    its('building') { should eq 'Big' }
    its('categories') { should eq ['Servers', 'Dev'] }
    its('assets') { should eq({ 'vendorPhone' => '311' }) }
  end
end
