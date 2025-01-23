control 'poller' do
  describe poller_package('foo') do
    it { should exist }
    its('filter') { should eq "(IPADDR != '0.0.0.0') & (categoryName == 'foo')" }
    its('specifics') { should eq ['10.0.0.1'] }
    its('include_ranges') { should eq [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/foo'] }
    its('rrd_step') { should eq 600 }
    its('remote') { should eq true }
    its('outage_calendars') { should eq ['ignore localhost on mondays'] }
    its('rras') { should eq ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732'] }
  end

  describe poller_package('create_if_missing') do
    it { should exist }
    its('filter') { should eq "(IPADDR != '0.0.0.0') & (categoryName == 'create_if_missing')" }
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
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('port') { should eq 161 }
    its('parameters') { should eq 'oid' => { 'value' => '.1.3.6.1.2.1.1.2.0' } }
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

  describe poller_service('SNMPBar2', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
  end
  describe poller_service('ICMPBar', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('ICMPBar2', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('ICMPBar3', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('Complex', 'bar') do
    it { should exist }
    its('time_out') { should eq 300 }
    its('port') { should eq 12 }
    its('pattern') { should eq '^Device&<![CDATA[/>CDATAConfig-(?<configType>.+)$' }
    its('parameters') do
      should eq(
      'page-sequence' => {
        'configuration' => "<page attribute='value'><farameter>text<!-- comment  -->more text</farameter></page>",
      }
    )
    end
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.PageSequenceMonitor' }
    its('class_parameters') do
      should eq(
      'key' => { 'value' => '400' },
      'other key' => {
        'configuration' => "<page attribute='value'><sarameter>text<!-- comment  -->more text</sarameter></page>",
      },
      'everything key' => {
        'configuration' => "<porg attribute='value'><qarameter>text<!-- comment  -->more text</qarameter></porg>",
      }
    )
    end
  end

  describe poller_service('ICMPBar4', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('ICMPBar5', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('ICMPBar6', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe poller_service('ICMPBar7', 'bar') do
    it { should exist }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => { 'value' => '65' }, 'retry' => { 'value' => '3' } }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end
end
