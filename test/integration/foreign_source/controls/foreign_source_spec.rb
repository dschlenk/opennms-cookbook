control 'foreign_source' do
  describe foreign_source('saucy-source', 1237) do
    it { should exist }
    its('scan_interval') { should eq '1w' }
  end
  describe foreign_source('dry-source', 1237) do
    it { should exist }
    its('scan_interval') { should eq '1d' }
  end
end
