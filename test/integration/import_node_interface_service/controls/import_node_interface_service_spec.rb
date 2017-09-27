# frozen_string_literal: true
control 'import_node_interface_service' do
  describe import_node_interface_service('ICMP', '72.72.72.74', 'dry-source', 'svcNodeId') do
    it { should exist }
  end
end
