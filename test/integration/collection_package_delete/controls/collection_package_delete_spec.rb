control 'collection_package_delete' do
	bar = {
		'filter' => "IPADDR != '0.0.0.0"
	}
	describe collection_package(bar) do
		it {should_not exist}
	end
	
	foo = {
		'filter' => "IPADDR != '0.0.0.0' & categoryName == 'foo'",
		'specifics' => ['10.0.0.1'],
		'include_ranges' => [{'begin' => '10.0.1.1', 'end' => '10.0.1.254'}],
		'exclude_ranges' => [{'begin' => '10.0.2.1', 'end' => '10.0.2.254'}],
		'include_urls' => ['file:/opt/opennms/etc/foo'],
		'store_by_if_alias' => true,
		'if_alias_domain' => 'foo.com',
		'remote' => true,
		'outage_calendars' => ['ignore localhost on mondays']
		
	}
	describe collection_package (foo) do
		it {should_not exist}
	end
end
