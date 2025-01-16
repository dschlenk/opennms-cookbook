control 'opennms' do
  describe package('opennms-core') do
    it { should be_installed }
    its('version') { should eq '33.1.2-1' }
  end
  describe package('opennms-webapp-jetty') do
    it { should be_installed }
    its('version') { should eq '33.1.2-1' }
  end
  describe service('opennms') do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end
end
