# frozen_string_literal: true
control 'delete_imported_node' do
  describe import_node('nodeC', 'dry-source') do
    it { should_not exist }
  end
end
