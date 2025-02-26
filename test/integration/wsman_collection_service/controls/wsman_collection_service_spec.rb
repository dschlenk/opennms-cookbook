control 'wsman_collection_service' do
  describe collection_service('WS-ManFoo', 'foo') do
    it { should exist }
    its('collection') { should eq 'foo' }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 4445 }
    its('thresholding_enabled') { should eq true }
  end

  describe collection_service('WS-Man', 'example1') do
    it { should exist }
    its('collection') { should eq 'default' }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq true }
  end
end
