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
    its('resolution_prefix') { should eq 'RESOLVED: ' }
    its('notify') { should eq nil }
  end

  describe notifd_autoack('exampl3/exampl3', 'exampl3/exampl3Down') do
    it { should exist }
    its('matches') { should eq %w(nodeid) }
    its('resolution_prefix') { should eq 'RESOLVED: ' }
    its('notify') { should eq nil }
  end

  describe notifd_autoack('example4/up', 'example4/down') do
    it { should exist }
    its('matches') { should eq %w(nodeid interfaceid serviceid) }
    its('resolution_prefix') { should eq 'EVERYTHING_IS_FINE_DOT_GIF: ' }
    its('notify') { should eq true }
  end

  describe notifd_autoack('example5/up', 'example5/down') do
    it { should_not exist }
  end

  describe notifd_autoack('example6/up', 'example6/down') do
    it { should_not exist }
  end
end
