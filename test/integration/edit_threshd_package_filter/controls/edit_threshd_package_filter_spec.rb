control 'edit_threshd_package_filter' do
  describe threshd_package('cheftest2') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0' & IPADDR != '1.1.1.1'" }
    its('specifics') { should eq ['172.17.17.1'] }
    its('include_ranges') { should eq [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.1.0.1', 'end' => '10.254.254.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/include2'] }
    its('services') { should eq [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }] }
  end
end
