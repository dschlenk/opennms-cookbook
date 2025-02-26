control 'statsd' do
  describe statsd_package('cheftest') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end

  describe statsd_package('emtee') do
    it { should exist }
    its('filter') { should eq nil }
  end

  describe statsd_package('changeme') do
    it { should exist }
    its('filter') { should eq "IPADDR != '1.1.1.1'" }
  end

  describe statsd_package('deleteme') do
    it { should_not exist }
  end

  describe statsd_package('ifmissing') do
    it { should exist }
    its('filter') { should eq "IPADDR != '127.0.0.1'" }
  end

  describe statsd_report('chefReport', 'cheftest') do
    it { should exist }
    its('description') { should eq 'testing report lwrp' }
    its('schedule') { should eq '0 30 2 * * ?' }
    its('retain_interval') { should eq 5_184_000_000 }
    its('status') { should eq 'off' }
    its('parameters') { should eq 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets' }
    its('class_name') { should eq 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor' }
  end

  describe statsd_report('testDefaultsReport', 'cheftest') do
    it { should exist }
    its('description') { should eq 'testing report lwrp defaults' }
    its('parameters') { should eq 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets' }
    its('schedule') { should eq '0 20 1 * * ?' }
    its('retain_interval') { should eq 2_592_000_000 }
    its('status') { should eq 'on' }
    its('class_name') { should eq 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor' }
  end

  describe statsd_report('foo', 'cheftest') do
    it { should exist }
    its('description') { should eq 'report to test updates withh' }
    its('schedule') { should eq '1 31 3 * * ?' }
    its('retain_interval') { should eq 4_073_999_999 }
    its('status') { should eq 'off' }
    its('class_name') { should eq 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor' }
  end

  describe statsd_report('bar', 'cheftest') do
    it { should exist }
    its('description') { should eq 'report to test :create_if_missing with' }
    its('schedule') { should eq '0 20 1 * * ?' }
    its('retain_interval') { should eq 2_592_000_000 }
    its('status') { should eq 'on' }
    its('class_name') { should eq 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor' }
  end

  describe statsd_report('baz', 'cheftest') do
    it { should_not exist }
  end

  describe statsd_report('null', 'nil') do
    it { should_not exist }
  end

  describe statsd_report('null', 'cheftest') do
    it { should_not exist }
  end
end
