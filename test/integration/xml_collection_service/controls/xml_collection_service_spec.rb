control 'xml_collection_service' do
  describe collection_service('XMLFoo', 'foo') do
    it { should exist }
    its('collection') { should eq 'foo' }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 8181 }
    its('thresholding_enabled') { should eq true }
  end

  describe collection_service('XML Service', 'example1') do
    it { should exist }
    its('collection') { should eq 'default' }
    its('status') { should eq 'on' }
  end

  describe collection_service('create_if_missing XML Service', 'example1') do
    it { should exist }
    its('collection') { should eq 'default' }
    its('status') { should eq 'off' }
  end
end
