control 'edit_threshd_package_ranges' do
  describe threshd_package('cheftest2') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
    its('specifics') { should eq ['172.17.17.1'] }
    its('include_ranges') { should eq [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.20.1', 'end' => '172.17.21.254' }] }
    its('exclude_ranges') { should eq [] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/include2'] }
    its('services') { should eq [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }] }
  end
end
