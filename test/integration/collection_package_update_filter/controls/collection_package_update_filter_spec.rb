control 'collection_package_update_filter' do
  describe collection_package('foo', true) do
    its('filter') { should eq "(IPADDR != '0.0.0.0') & (categoryName == 'update_foo')" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foo'] }
    its('store_by_if_alias') { should eq true }
    its('if_alias_domain') { should eq 'foo.com' }
    its('outage_calendars') { should eq ['ignore localhost on mondays'] }
  end
end
