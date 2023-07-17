control 'delete_threshd_package' do
  describe threshd_package('cheftest2') do
    it { should_not exist }
  end
end
