control 'collection_package_delete' do
  describe collection_package('foo', true) do
    it { should_not exist }
  end

  describe collection_package('bar', false) do
    it { should_not exist }
  end
end
