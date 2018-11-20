control 'collection_package_update_sbifalias' do
	describe collection_package'foo' do
		its('remote'){should eq true}
		its('store_by_if_alias') { should eq true }
	end
end
