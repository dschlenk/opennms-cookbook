# frozen_string_literal: true
control 'statsd' do
  describe statsd_package('cheftest') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end

  describe statsd_package('emtee') do
    it { should exist }
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
end
