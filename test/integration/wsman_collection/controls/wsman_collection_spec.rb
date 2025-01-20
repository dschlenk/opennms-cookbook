control 'wsman_collection' do
  describe wsman_collection('foo') do
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
    its('include_system_definitions') { should eq true }
  end

  # minimal
  describe wsman_collection('bar') do
    it { should exist }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
    its('include_system_definitions') { should eq false }
  end

  describe wsman_collection('default') do
    it { should exist }
    its('rrd_step') { should eq 301 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
    its('include_system_definitions') { should eq false }
    its('include_system_definition') { should eq ['Microsoft Windows (All Versions)', 'Dell iDRAC (All Version)', 'Dell iDRAC 8'] }
  end

  describe wsman_collection('create_if_missing') do
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
    its('include_system_definitions') { should eq true }
  end
end
