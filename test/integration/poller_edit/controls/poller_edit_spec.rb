# frozen_string_literal: true
control 'poller_edit' do
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
    its('time_out') { should eq 3000 }
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
    its('parameters') { should eq 'oid' => '.1.3.6.1.2.1.1.2.1' }
  end

  describe poller_service('ICMPBar', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_001 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => '65', 'retry' => '3' }
  end

  describe poller_service('ICMPBar2', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => '65', 'retry' => '3' }
  end

  describe poller_service('ICMPBar3', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'on' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => '65', 'retry' => '3' }
  end

  describe poller_service('ICMPBar4', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5005 }
    its('parameters') { should eq 'packet-size' => '65', 'retry' => '3' }
  end

  describe poller_service('ICMPBar5', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'packet-size' => '32' }
  end

  describe poller_service('ICMPBar6', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'oid' => '.1.3.6.1.2.1.1.2.2' }
  end
end
