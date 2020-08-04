# frozen_string_literal: true
control 'wsman_collection_service' do
  describe wsman_collection_service('WS-ManFoo', 'foo', 'foo') do
    it { should exist }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 4445 }
    its('thresholding_enabled') { should eq true }
  end

  describe wsman_collection_service('Ws-man', 'default', 'example1') do
    it { should exist }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 3000 }
    its('retry_count') { should eq 1 }
    its('thresholding_enabled') { should eq false }
  end
end
