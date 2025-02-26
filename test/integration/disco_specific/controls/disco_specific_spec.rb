control 'disco_specific' do
  describe disco_specific('10.10.1.1', 'Chicago') do
    it { should exist }
    its('retry_count') { should be == 13 }
    its('discovery_timeout') { should be == 4000 }
    its('foreign_source') { should eq 'bears' }
  end

  describe disco_specific('10.10.1.2') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('10.3.0.2', 'Minneapolis') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('10.3.0.2', 'Milwaukee') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should be == 4001 }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('10.3.0.2') do
    it { should exist }
    its('retry_count') { should be == 13 }
    its('discovery_timeout') { should be == 4000 }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('10.3.0.1', 'Detroit') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
    its('foreign_source') { should eq 'disco-specific-source' }
  end

  describe disco_specific('127.0.0.1') do
    it { should exist }
    its('retry_count') { should be == 14 }
    its('discovery_timeout') { should be == 4001 }
    its('foreign_source') { should eq 'bears' }
  end

  describe disco_specific('127.0.0.2') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('127.0.0.3', 'St Louis Park') do
    it { should_not exist }
  end

  describe disco_specific('127.0.0.3') do
    it { should exist }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
    its('foreign_source') { should eq nil }
  end

  describe disco_specific('127.0.0.4') do
    it { should_not exist }
  end
end
