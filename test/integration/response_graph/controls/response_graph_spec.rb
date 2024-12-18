# frozen_string_literal: true
control 'response_graph' do
  describe poller_service('ONMS', 'example1') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.HttpMonitor' }
    its('port') { should eq 8980 }
    its('parameters') { should eq 'url' => '/opennms/login.jsp', 'rrd-repository' => '/opt/opennms/share/rrd/response', 'rrd-base-name' => 'onms', 'ds-name' => 'onms' }
  end

  # describe foreign_source('dry-source') do
  #   it { should exist }
  # end

  # describe import('dry-source', 'dry-source') do
  #   it { should exist }
  # end

  # describe import_node('20180220151655', 'dry-source') do
  #   it { should exist }
  #   its('node_label') { should eq 'responseGraphTestNode' }
  #   its('building') { should eq 'HQ' }
  #   its('categories') { should eq %w(Servers Test) }
  # end

  # describe import_node_interface('127.0.0.1', 'dry-source', '20180220151655') do
  #   it { should exist }
  # end

  # describe import_node_interface_service('ONMS', '127.0.0.1', 'dry-source', '20180220151655') do
  #   it { should exist }
  # end

  describe response_graph('onms') do
    it { should exist }
    its('long_name') { should eq 'ONMS' }
    its('columns') { should eq ['onms'] }
    its('type') { should eq %w(responseTime distributedStatus) }
    its('command') { should eq '--title="ONMS Response Time" --vertical-label="Seconds" DEF:rtMills={rrd1}:onms:AVERAGE DEF:minRtMicro={rrd1}:onms:MIN DEF:maxRtMicro={rrd1}:onms:MAX CDEF:rt=rtMills,1000,/ CDEF:minRt=minRtMills,1000,/ CDEF:maxRt=maxRtMills,1000,/ LINE1:rt#0000ff:"Response Time" GPRINT:rt:AVERAGE:" Avg  \\: %8.2lf %s" GPRINT:rt:MIN:"Min  \\: %8.2lf %s" GPRINT:rt:MAX:"Max  \\: %8.2lf %s\\n"' }
  end

  describe response_graph('onms.avg') do
    it { should exist }
    its('long_name') { should eq 'OpenNMS Response Time' }
    its('columns') { should eq ['onms'] }
    its('type') { should eq ['responseTime'] }
    its('command') { should eq '--title="OpenNMS Web Interface Response Time"  --vertical-label="Milliseconds" DEF:avgrt={rrd1}:onms:AVERAGE LINE2:avgrt#0000ff:"Response Time" GPRINT:avgrt:AVERAGE:" Avg \\: %8.2lf %s\\n' }
  end
end
