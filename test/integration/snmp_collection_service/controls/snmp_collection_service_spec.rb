# frozen_string_literal: true
control 'snmp_collection_service' do
  describe snmp_collection_service('SNMP', 'baz', 'foo') do
    it { should exist }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 1161 }
    its('thresholding_enabled') { should eq true }
  end

  describe snmp_collection_service('SNMP-bar', 'default', 'bar') do
    it { should exist }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 3000 }
    its('retry_count') { should eq 1 }
    its('port') { should eq 161 }
    its('thresholding_enabled') { should eq false }
  end
end
