# frozen_string_literal: true
control 'snmp_collection' do
  describe snmp_collection('baz') do
    it { should exist }
    its('max_vars_per_pdu') { should eq 75 }
    its('snmp_stor_flag') { should eq 'all' }
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
  end

  describe snmp_collection 'qux' do
    it { should exist }
    its('snmp_stor_flag') { should eq 'select' }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end
end
