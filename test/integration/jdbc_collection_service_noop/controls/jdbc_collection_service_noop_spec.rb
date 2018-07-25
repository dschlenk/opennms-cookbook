# frozen_string_literal: true
control 'jdbc_collection_service_noop' do
  describe jdbc_collection_service('JDBCFoo', 'foo', 'foo') do
    it { should exist }
    its('interval') { should eq 500000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 6000 }
    its('retry_count') { should eq 3 }
    its('port') { should eq 88 }
    its('thresholding_enabled') { should eq false }
    its('driver') { should eq 'org.place.Driver' }
    its('user') { should eq 'jimmy' }
    its('password') { should eq 'johnny' }
    its('url') { should eq 'jdbc:place:server:database' }
  end
end
