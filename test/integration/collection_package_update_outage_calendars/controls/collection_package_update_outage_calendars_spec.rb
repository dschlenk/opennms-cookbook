control 'collection_package_update_outage_calendars' do
  describe collection_package 'foo' do
    its('filter') { should eq "IPADDR != '1.1.1.1' & categoryName == 'update_foo'" }
    its('outage_calendars') { should eq ['update localhost on tuesday'] }
  end
end
