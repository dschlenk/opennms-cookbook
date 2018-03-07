# frozen_string_literal: true
control 'notifd_autoack' do
  describe notifd_autoack('uei.opennms.org/example/exampleUp', 'uei.opennms.org/example/exampleDown') do
    it { should exist }
    its('resolution_prefix') { should eq 'RECTIFIED: ' }
    its('notify') { should eq false }
    its('matches') { should eq %w(nodeid interfaceid serviceid) }
  end

  describe notifd_autoack('example2/exampleFixed', 'example2/exampleBroken') do
    it { should exist }
    its('matches') { should eq %w(nodeid) }
  end
end
