control 'collection_package_update_outage_calendars' do
	describe collection_package'foo' do
		its('remote'){should eq true}
		its('outage_calendars') {should eq ['update localhost on tuesday']}
	end
end