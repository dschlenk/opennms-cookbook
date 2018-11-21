control 'collection_package_update_includes' do
	describe collection_package 'foo' do
		its('filter') {should eq "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"}
		its('include_ranges') {should eq [{'begin' => '10.0.1.1', 'end' => '10.0.1.254'}]}
	end
end