control 'jdbc_collection_service' do
  describe collection_service('JDBCFoo', 'foo') do
    it { should exist }
    its('parameters') { should cmp 'driver' => 'org.postgresql.Driver', 'user' => 'wibble', 'password' => 'wobble', 'url' => 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble' }
    its('collection') { should eq 'foo' }
    its('interval') { should eq 400000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('port') { should eq 15432 }
    its('thresholding_enabled') { should eq true }
    its('retry_count') { should eq 10 }
  end

  describe collection_service('JDBC', 'example1') do
    it { should exist }
    its('parameters') { should cmp 'driver' => 'org.postgresql.Driver', 'user' => 'wibble', 'password' => 'wobble', 'url' => 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble' }
    its('collection') { should eq 'default' }
    # values derived from defaults
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end

  describe file('/opt/opennms/lib/jdbc.jar') do
    it { should exist }
    its('mode') { should cmp '0664' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end
end
