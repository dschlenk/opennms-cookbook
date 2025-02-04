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
  describe system_def('create_if_missing') do
    it { should exist }
  end
end
