control 'wallboard_mod' do
  describe wallboard('fooboard') do
    it { should exist }
    it { should be_default }
  end

  describe wallboard('schlazorboard') do
    it { should exist }
    it { should_not be_default }
  end

  describe wallboard('barboard') do
    it { should_not exist }
  end
end
