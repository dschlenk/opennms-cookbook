control 'jdbc_collection' do
  describe jdbc_collection('foo') do
    it { should exist }
    its('rrd_step') { should eq 601 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:731'] }
  end

  describe jdbc_collection('bar') do
    it { should exist }
    its('rrd_step') { should eq 302 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end
end
