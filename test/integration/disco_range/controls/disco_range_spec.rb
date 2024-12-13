control 'disco_range' do
  describe disco_range('include', '10.0.0.1', '10.0.0.254', 'Detroit') do
    it { should exist }
    its('retry_count') { should eq 37 }
    its('discovery_timeout') { should eq 6000 }
    its('foreign_source') { should eq 'disco-source' }
  end

  describe disco_range('exclude', '10.0.0.10', '10.0.0.20', 'Detroit') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_range('include', '192.168.0.1', '192.168.254.254') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_range('include', '10.1.0.1', '10.1.0.254', 'Detroit') do
    it { should exist }
    its('foreign_source') { should eq 'disco-source' }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_range('include', '10.2.0.1', '10.2.0.10') do
    it { should exist }
    its('foreign_source') { should eq 'ten-dot-two-dot-zero-dot-one-through-ten' }
    its('retry_count') { should eq 39 }
    its('discovery_timeout') { should eq 6001 }
  end

  describe disco_range('exclude', '10.5.0.1', '10.6.0.1', 'Mars') do
    it { should_not exist }
  end

  describe disco_range('include', '10.2.0.1', '10.2.0.10', 'Mars') do
    it { should_not exist }
  end
end
