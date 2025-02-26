control 'jdbc_query' do
  describe jdbc_query('ifaceServicesQuery', 'foo') do
    it { should_not exist }
  end
end
