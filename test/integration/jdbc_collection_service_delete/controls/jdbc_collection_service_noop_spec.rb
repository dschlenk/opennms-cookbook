control 'jdbc_collection_service_delete' do
  describe collection_service('JDBCFoo', 'foo') do
    it { should_not exist }
  end
end
