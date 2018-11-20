control 'collection_package_update_includes' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('include_ranges') {should eq [{'begin' => '10.0.1.1', 'end' => '10.0.1.254'}]}
	end
end