control 'service_detector_delete' do
  describe service_detector('I C M P', 'another-source') do
    it { should_not exist }
  end
end
