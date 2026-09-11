control 'trapd-download-unmasked' do
  impact 1.0

  title 'Trapd download endpoint returns unmasked secrets'

  describe user['authPassphrase'] do
    it { should_not match(/^\*+$/) }
  end

  describe user['privacyPassphrase'] do
    it { should_not match(/^\*+$/) }
  end
end
