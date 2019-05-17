control 'collection_package_update' do
  describe collection_package 'foo' do
    its('filter') { should eq "IPADDR != '0.0.0.0' & categoryName == 'foobar'" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.10.10.10', 'end' => '10.10.10.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.1.1.1', 'end' => '10.2.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foobar'] }
    its('store_by_if_alias') { should eq true }
    its('if_alias_domain') { should eq 'foobar.com' }
    its('outage_calendars') { should eq ['ignore localhost on foobar'] }
  end
end
