control 'service_detector_delete' do
  describe service_detector('I C M P', 'another-source', 1244) do
    it { should_not exist }
  end
end
