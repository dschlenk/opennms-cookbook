control 'jdbc_collection_service_delete' do
  describe jdbc_collection_service('JDBCFoo', 'foo', 'foo') do
    it { should_not exist }
  end
end
