control 'poller_edit' do
  describe poller_package('bar') do
    it { should exist }
    its('filter') { should eq "IPADDR == '10.0.0.1'" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq ['begin' => '10.0.0.1', 'end' => '10.0.0.1'] }
    its('exclude_ranges') { should eq ['begin' => '10.0.2.1', 'end' => '10.0.2.254'] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/bar'] }
    its('rrd_step') { should eq 601 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4033', 'RRA:AVERAGE:0.5:24:2977', 'RRA:AVERAGE:0.5:576:733', 'RRA:MAX:0.5:576:733', 'RRA:MIN:0.5:576:733'] }
    its('remote') { should eq false }
    its('outage_calendars') { should eq ['ignore localhost on tuesdays'] }
  end

  describe poller_package('foo') do
    it { should exist }
    its('filter') { should eq "(IPADDR != '0.0.0.0')" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foo'] }
    its('rrd_step') { should eq 600 }
    its('remote') { should eq true }
    its('outage_calendars') { should eq ['ignore localhost on mondays'] }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
  end

  describe poller_service('SNMP', 'foo') do
    it { should exist }
    its('interval') { should eq 700_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('time_out') { should eq 5001 }
    its('port') { should eq 162 }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('SNMPBar', 'bar') do
    it { should exist }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('SNMPBar2', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
    its('interval') { should eq 300_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('time_out') { should eq 5002 }
    its('port') { should eq 165 }
    its('parameters') { should eq 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.1' } }
  end

  describe poller_service('ICMPBar', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_001 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
  end

  describe poller_service('ICMPBar2', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
  end

  describe poller_service('ICMPBar3', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'on' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
  end

  describe poller_service('ICMPBar4', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5005 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
  end

  describe poller_service('ICMPBar5', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '32' } }
  end

  describe poller_service('ICMPBar6', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.2' } }
  end
end
