# frozen_string_literal: true
control 'disco_url' do
  describe disco_url('file:/opt/opennms/etc/include') do
    it { should exist }
    its('file_name') { should eq '/opt/opennms/etc/include' }
    its('retry_count') { should eq 13 }
    its('discovery_timeout') { should eq 4000 }
  end

  describe disco_url('http://example.com/include') do
    it { should exist }
  end
  du = disco_url('http://other.net/things')
  if du.location.nil?
    describe du do
      it { should exist }
      its('foreign_source') { should eq 'disco-url-source' }
    end
  else
    describe du do
      it { should exist }
      its('location') { should eq 'Detroit' }
      its('foreign_source') { should eq 'disco-url-source' }
    end
  end
end
