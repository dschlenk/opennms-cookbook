control 'collection_package_update_urls' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('include_urls') { should eq ['file:/opt/opennms/etc/update_foo'] }
	end
end