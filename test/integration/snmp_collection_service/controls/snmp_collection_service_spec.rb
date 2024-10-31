control 'snmp_collection_service' do
  describe collection_service('SNMP', 'foo') do
    it { should exist }
    its('collection') { should eq 'baz' }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 1161 }
    its('thresholding_enabled') { should eq true }
  end

  describe collection_service('SNMP-bar', 'bar') do
    it { should exist }
    its('collection') { should eq 'default' }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end
end
