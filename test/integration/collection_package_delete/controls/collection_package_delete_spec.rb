control 'collection_package_delete' do
	describe collection_package 'foo' do
		it {should_not exist}
	end
	
	describe collection_package('bar') do
		it {should_not exist}
	end
end
