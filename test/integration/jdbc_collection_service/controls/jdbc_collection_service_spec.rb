# frozen_string_literal: true
control 'jdbc_collection_service' do
  describe jdbc_collection_service('JDBCFoo', 'foo', 'foo') do
    it { should exist }
    its('interval') { should eq 400000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('port') { should eq 15432 }
    its('thresholding_enabled') { should eq true }
    its('driver') { should eq 'org.postgresql.Driver' }
    its('user') { should eq 'wibble' }
    its('password') { should eq 'wobble' }
    its('retry_count') { should eq 10 }
    its('url') { should eq 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble' }
  end

  describe jdbc_collection_service('JDBC', 'default', 'example1') do
    it { should exist }
    its('driver') { should eq 'org.postgresql.Driver' }
    its('user') { should eq 'wibble' }
    its('password') { should eq 'wobble' }
    its('url') { should eq 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble' }
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
