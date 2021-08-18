# frozen_string_literal: true
control 'webopts' do
  describe file('/opt/opennms/etc/jetty.keystore') do
    it { should exist }
  end

  # Version 27 did not use test/fixtures/cookbooks/onms_lwrp_test/attributes/default.rb anymore. I comment it out and that why we don't need test either
  # describe port('8443') do
  #  it { should be_listening }
  #  its('processes') { should include 'java' }
  # end
end
