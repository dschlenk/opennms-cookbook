control 'jdbc_collection' do
  describe jdbc_collection('foo') do
    it { should_not exist }
  end

  describe jdbc_collection('MySQL-Global-Stats') do
    it { should_not exist }
  end

  describe jdbc_collection('bar') do
    it { should exist }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end
end
