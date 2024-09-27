%w(opennms-core opennms-webapp-jetty opennms-plugin-protocol-nsclient opennms-plugin-provisioning-snmp-hardware-inventory opennms-plugin-provisioning-snmp-asset opennms-plugin-northbounder-jms).each do |p|
  describe package(p) do
    it { should be_installed }
    its('version') { should eq '33.0.8-1' }
  end
end
describe service('opennms') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end
