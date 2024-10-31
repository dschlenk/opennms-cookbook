control 'jdbc_collection_service_noop' do
  describe collection_service('JDBCFoo', 'foo') do
    it { should exist }
    its('parameters') { should cmp 'url' => 'jdbc:place:server:database', 'password' => 'johnny', 'user' => 'jimmy', 'driver' => 'org.place.Driver' }
    its('collection') { should eq 'foo' }
    its('interval') { should eq 500000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 6000 }
    its('retry_count') { should eq 3 }
    its('port') { should eq 88 }
    its('thresholding_enabled') { should eq false }
  end
end
