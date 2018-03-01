# frozen_string_literal: true
control 'disco_specific' do
  describe disco_specific('10.10.1.1') do
    it { should exist }
    its('retry_count') { should eq 13 }
    its('discovery_timeout') { should eq 4000 }
  end

  describe disco_specific('10.10.1.2') do
    it { should exist }
  end

  # horizon <- 16 doesn't do location
  ds = disco_specific('10.3.0.1')
  if ds.location.nil?
    describe ds do
      it { should exist }
      its('foreign_source') { should eq 'disco-specific-source' }
    end
  else
    describe ds do
      it { should exist }
      its('location') { should eq 'Detroit' }
      its('foreign_source') { should eq 'disco-specific-source' }
    end
  end
end
