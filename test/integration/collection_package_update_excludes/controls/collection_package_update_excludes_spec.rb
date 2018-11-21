control 'collection_package_update_excludes' do
	describe collection_package 'foo' do
		its('remote'){should eq true}
		its('filter') {should eq "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"}
		its('exclude_ranges') {should eq [{'begin' => '10.0.2.1', 'end' => '254.254.254.254'}]}
	end
end