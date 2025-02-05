control 'threshd_service' do
  describe threshd_package('cheftest2') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
    its('specifics') { should eq ['172.17.17.1'] }
    its('include_ranges') { should eq [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.1.0.1', 'end' => '10.254.254.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/include2'] }
    its('services') { should eq [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }, { 'name' => 'WS-Man', 'interval' => 300000, 'status' => 'on', 'user-defined' => true, 'params' => { 'thresholding-group' => 'cheftest2' } }, { 'name' => 'WS-Man2', 'interval' => 300000, 'status' => 'off', 'user-defined' => false }] }
  end

  describe threshd_package('mib2') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0' & IPADDR != '255.255.255.255'" }
    its('specifics') { should eq ['1.0.0.1', '1.0.0.2'] }
    its('include_ranges') { should eq [{ 'begin' => '1.0.0.1', 'end' => '223.255.255.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '224.0.0.1', 'end' => '255.255.255.255' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/include'] }
    its('services') { should eq [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'off', 'params' => { 'thresholding-group' => 'mibtoo' } }, { 'name' => 'SNMPv3', 'interval' => 600000, 'status' => 'on' }] }
  end

  describe threshd_package('hrstorage') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0' & (nodeSysOID LIKE '.1.3.6.1.4.1.311.%' | nodeSysOID LIKE '.1.3.6.1.4.1.2.3.1.2.1.1.3.%' | nodeSysOID LIKE '.1.3.6.1.4.1.8072.%')" }
    its('specifics') { should be.nil? }
    its('include_ranges') { should eq [{ 'begin' => '1.1.1.1', 'end' => '254.254.254.254' }, { 'begin' => '::1', 'end' => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' }] }
    its('exclude_ranges') { should be.nil? }
    its('include_urls') { should be.nil? }
    its('services') { should be.nil? }
  end
  describe threshd_package('cheftest2') do
    it { should exist }
  end
end
