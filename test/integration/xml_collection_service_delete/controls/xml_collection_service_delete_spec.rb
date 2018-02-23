# frozen_string_literal: true
control 'xml_collection_service_delete' do
  describe xml_collection_service('XML', 'default', 'example1') do
    it { should_not exist }
  end
end
