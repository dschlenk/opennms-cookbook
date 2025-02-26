control 'disco_url' do
  describe disco_url('include', 'file:/opt/opennms/etc/include', 'Detroit') do
    it { should exist }
    its('foreign_source') { should eq 'disco-url-source' }
    its('file_name') { should eq '/opt/opennms/etc/include' }
    its('retry_count') { should be == 13 }
    its('discovery_timeout') { should be == 4000 }
  end

  describe disco_url('include', 'http://example.com/include') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('file_name') { should eq nil }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_url('include', 'http://other.net/things', 'Detroit') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('file_name') { should eq nil }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_url('include', 'https://example.com/exclude', 'Jupiter') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('file_name') { should eq nil }
    its('retry_count') { should be == 14 }
    its('discovery_timeout') { should be == 400 }
  end

  describe disco_url('exclude', 'https://example.com/excludes') do
    it { should exist }
    its('foreign_source') { should eq nil }
    its('file_name') { should eq nil }
    its('retry_count') { should eq nil }
    its('discovery_timeout') { should eq nil }
  end

  describe disco_url('include', 'http://zombo.com') do
    it { should_not exist }
  end

  describe disco_url('include', 'http://example.com/include', 'Uranus') do
    it { should_not exist }
  end
end
