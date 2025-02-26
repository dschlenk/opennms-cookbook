control 'xml_collection_service_delete' do
  describe collection_service('XML', 'example1') do
    it { should_not exist }
  end
end
