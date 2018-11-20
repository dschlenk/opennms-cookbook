control 'collection_package_update_filter' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('filter') {should eq "(IPADDR != '0.0.0.0') & (categoryName == 'update_foo')"}
	end
	
	describe collection_package 'bar' do
		it {should exist}
		its('filter') {should eq "(IPADDR != '10.0.0.10')"}
	end
end
