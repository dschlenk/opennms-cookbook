control 'localhost' do
  describe foreign_source('localhost') do
    it { should exist }
  end
  describe import('localhost', 'localhost') do
    it { should exist }
  end
  describe import_node('1', 'localhost') do
    it { should exist }
    its('node_label') { should eq 'localhost' }
  end
  %w(127.0.0.1 10.0.2.15).each do |iface|
    describe import_node_interface(iface, 'localhost', '1') do
      it { should exist }
      its('managed') { should eq true }
      its('snmp_primary') { should eq 'P' }
    end
    %w(SNMP ICMP).each do |svc|
      describe import_node_interface_service(svc, iface, 'localhost', '1') do
        it { should exist }
      end
    end
  end
end
