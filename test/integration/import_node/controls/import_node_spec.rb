# frozen_string_literal: true
control 'import_node' do
  describe import_node('nodeA_ID', 'dry-source') do
    it { should exist }
    its('node_label') { should eq 'nodeA' }
  end
end
