control 'collection_package_update_specifics' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('filter') {should eq "(IPADDR != '1.1.1.1') & (categoryName == 'update_foo')"}
		its('specifics') { should eq ['10.1.1.1'] }
	end
end
