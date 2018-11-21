control 'collection_package_update_urls' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('filter') {should eq "(IPADDR != '1.1.1.1') & (categoryName == 'update_foo')"}
		its('include_urls') { should eq ['file:/opt/opennms/etc/update_foo'] }
	end
end