resp = inspec.http('http://localhost:8980/opennms/api/v2/trapd/download?format=xml', auth: { user: 'admin', pass: 'admin' }, headers: { 'Accept': 'application/xml' })
if resp.status == 200
  doc = REXML::Document.new(resp.body)
elsif doc.nil?
  doc = REXML::Document.new(inspec.file('/opt/opennms/etc/trapd-configuration.xml').content)
end
cfg = doc.root unless doc.nil?
control 'trapd-config' do
  impact 1.0
  title 'Trapd configuration is configured'

  describe cfg['batch-interval'] do
    it { should eq '200' }
  end

  describe cfg['batch-size'] do
    it { should eq '500' }
  end

  describe cfg['include-raw-message'] do
    it { should eq 'true' }
  end

  describe cfg['new-suspect-on-trap'] do
    it { should eq 'false' }
  end

  describe cfg['queue-size'] do
    it { should eq '5000' }
  end

  describe cfg['snmp-trap-address'] do
    it { should eq '0.0.0.0' }
  end

  describe cfg['snmp-trap-port'] do
    it { should eq '1162' }
  end

  describe cfg['threads'] do
    it { should eq '8' }
  end

  describe cfg['use-address-from-varbind'] do
    it { should eq 'true' }
  end
end
