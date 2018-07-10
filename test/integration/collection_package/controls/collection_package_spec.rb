# frozen_string_literal: true
control 'collection_package' do
  describe collection_package('foo') do
    its('filter') { should eq "(IPADDR != '0.0.0.0') & (categoryName == 'foo')" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foo'] }
    its('store_by_if_alias') { should eq true }
    its('if_alias_domain') { should eq 'foo.com' }
    its('remote') { should eq true }
    its('outage_calendars') { should eq ['ignore localhost on mondays'] }
  end

  describe collection_package('bar') do
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end
end
