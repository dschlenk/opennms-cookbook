control 'plugins' do
  describe 'opennms::plugins' do
    it 'installs opennms plugins' do
      expect(package('opennms-plugin-provisioning-snmp-asset')).to be_installed
      expect(package('opennms-plugin-provisioning-snmp-hardware-inventory')).to be_installed
    end
  end
end
