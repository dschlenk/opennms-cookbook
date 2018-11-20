control 'collection_package_update_excludes' do
	describe collection_package'foo' do
		it {should exist}
		its('remote'){should eq true}
		its('exclude_ranges') {should eq 'begin' => '10.0.2.1', 'end' => '254.254.254.254'}
	end
end