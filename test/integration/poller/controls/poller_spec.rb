# frozen_string_literal: true
control 'poller' do
  describe poller_package('foo') do
    it { should exist }
    its('filter') { should eq "(IPADDR != '0.0.0.0') & (categoryName == 'foo')" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foo'] }
    its('rrd_step') { should eq 600 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
  end

  describe poller_service('SNMP', 'foo') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('port') { should eq 161 }
    its('params') { should eq 'oid' => '.1.3.6.1.2.1.1.2.0' }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
  end

  describe poller_package('bar') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end

  describe poller_service('SNMPBar', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
  end
end
