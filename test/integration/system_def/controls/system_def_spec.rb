# frozen_string_literal: true
control 'system_def' do
  describe system_def('Cisco Routers') do
    it { should exist }
    its('groups') { should include 'mib2-tcp' }
    its('groups') { should include 'mib2-powerethernet' }
  end
  describe system_def('Cisco ASA5510sy') do
    it { should exist }
    its('groups') { should_not include 'cisco-pix' }
    its('groups') { should_not include 'cisco-memory' }
  end
  describe system_def('createifmissing') do
    it { should exist }
    its('file_name') { should eq 'foo.xml' }
    its('sysoid') { should eq  '1.3.6.1.2.1.1.1.0' }
    its('sysoid_mask') { should eq nil }
    its('ip_addrs') { should eq ['192.168.1.1', '192.168.1.2'] }
    its('ip_addr_masks') { should eq ['255.255.255.0', '255.255.255.0'] }
  end
end
