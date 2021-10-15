# frozen_string_literal: true
control 'webopts' do
  describe file('/opt/opennms/etc/jetty.keystore') do
    it { should exist }
  end

  describe port('8443') do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end
