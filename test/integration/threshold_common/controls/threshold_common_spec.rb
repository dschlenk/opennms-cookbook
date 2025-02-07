control 'threshold_common' do
  describe poller_service('ICMP', 'example1') do
    it { should exist }
    its('parameters') { should eq 'rrd-repository' => { 'value' => '/opt/opennms/share/rrd/response' }, 'rrd-base-name' => { 'value' => 'icmp' }, 'ds-name' => { 'value' => 'icmp' }, 'thresholding-enabled' => { 'value' => 'true' } }
    its('status') { should eq 'on' }
    its('time_out') { should eq 3000 }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.IcmpMonitor' }
  end

  describe threshd_package('cheftest') do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
    its('specifics') { should eq ['172.17.16.1'] }
    its('include_ranges') { should eq [{ 'begin' => '172.17.13.1', 'end' => '172.17.13.254' }, { 'begin' => '172.17.20.1', 'end' => '172.17.20.254' }] }
    its('exclude_ranges') { should eq [{ 'begin' => '10.0.0.1', 'end' => '10.254.254.254' }] }
    its('include_urls') { should eq ['file:/opt/opennms/etc/include'] }
    its('services') { should eq [{ 'name' => 'ICMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest' } }] }
  end

  describe threshold_group('cheftest') do
    it { should exist }
    its('rrd_repository') { should eq '/opt/opennms/share/rrd/response' }
  end

  describe event('uei.opennms.org/thresholdTest/testThresholdExceeded', 'events/chef-threshold.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: testThresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe that tests thresholds has been exceeded.</p>' }
    its('logmsg') { should eq 'Chef test threshold exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Minor' }
  end

  describe event('uei.opennms.org/thresholdTest/testThresholdRearmed', 'events/chef-threshold.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: testThresholdRearmed' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe that tests thresholds has been rearmed.</p>' }
    its('logmsg') { should eq 'Chef test threshold rearmed.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should eq true }
    its('severity') { should eq 'Normal' }
  end

  describe threshold_group('mib2') do
    it { should exist }
    its('rrd_repository') { should eq '/var/opennms/rrd/snmp' }
  end

  describe threshold_group('hrstorage') do
    it { should_not exist }
  end

  describe threshold_group('noop-create_if_missing') do
    it { should_not exist }
  end

  describe threshold_group('create_if_missing') do
    it { should exist }
    its('rrd_repository') { should eq '/opt/opennms/share/rrd/snmp' }
  end
end
