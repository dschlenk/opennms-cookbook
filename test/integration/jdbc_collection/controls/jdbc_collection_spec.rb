# frozen_string_literal: true
control 'jdbc_collection' do
  describe jdbc_collection('foo') do
    it { should exist }
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
  end

  describe jdbc_collection('bar') do
    it { should exist }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end

  describe jdbc_collection('create_if_missing') do
    it { should exist }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end

  describe jdbc_collection('noop_create_if_missing') do
    it { should_not exist }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end  
end
