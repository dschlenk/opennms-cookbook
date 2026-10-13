control 'foreign_source' do
  describe foreign_source('saucy-source') do
    it { should exist }
    its('scan_interval') { should eq '1w' }
  end
  describe foreign_source('dry-source') do
    it { should exist }
    its('scan_interval') { should eq '1d' }
  end
end
