control 'collection_package_update_ifaliasdomain' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('filter') {should eq "(IPADDR != '1.1.1.1') & (categoryName == 'update_foo')"}
		its('if_alias_domain') {should eq 'updated_foo.com'}
	end
end
