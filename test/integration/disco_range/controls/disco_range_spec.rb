# frozen_string_literal: true
control 'disco_range' do
  describe disco_range('include', '10.0.0.1', '10.0.0.254') do
    it { should exist }
    its('retry_count') { should eq 37 }
    its('discovery_timeout') { should eq 6000 }
  end

  describe disco_range('exclude', '192.168.0.1', '192.168.254.254') do
    it { should exist }
  end

  describe disco_range('include', '10.1.0.1', '10.1.0.254') do
    it { should exist }
    its('location') { should eq 'Detroit' }
    its('foreign_source') { should eq 'disco-source' }
  end
end
