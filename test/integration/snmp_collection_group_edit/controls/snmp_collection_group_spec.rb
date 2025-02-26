# frozen_string_literal: true
control 'snmp_collection_group' do
  describe snmp_collection_group('wibble-wobble', 'wibble-wobble.xml', 'baz') do
    it { should exist }
    its('system_def') { should eq 'Wibble' }
    its('exclude_filters') { should eq [] }
  end

  describe snmp_collection_group('apache2', 'apache2.xml', 'baz') do
    it { should exist }
    its('system_def') { should eq 'nonsense' }
    acontent = <<-EOL
<?xml version="1.0"?>
<datacollection-group name="apache2">
  <group name="status" ifType="ignore">
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="5" alias="reqPerSec" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="6" alias="bytesPerSec" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="7" alias="bytesPerReq" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="8" alias="busyWorkers" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="9" alias="idleWorkers" type="integer"/>
  </group>
  <group name="scoreboard" ifType="ignore">
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="10" alias="waitCon" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="11" alias="startingUp" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="12" alias="readReq" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="13" alias="sendRep" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="14" alias="keepalive" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="15" alias="dnslookup" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="16" alias="closeCon" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="17" alias="logging" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="18" alias="graceFin" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="19" alias="idleCleanup" type="integer"/>
    <mibObj oid=".1.3.6.1.4.1.8072.1.3.2.4.1.2.6.97.112.97.99.104.101" instance="20" alias="openSlot" type="integer"/>
  </group>
  <systemDef name="Net-SNMP (Apache2)">
    <sysoidMask>.1.3.6.1.4.1.8072.3.</sysoidMask>
    <collect>
      <includeGroup>status</includeGroup>
      <includeGroup>scoreboard</includeGroup>
    </collect>
  </systemDef>
</datacollection-group>
EOL
    its('file_content') { should eq acontent }
  end

  describe snmp_collection_group('Zeus', 'zeus.xml', 'default') do
    it { should exist }
    its('exclude_filters') { should eq [ '^.*$', '^.*+$' ] }
  end

  describe snmp_collection_group('Didactum-Monitoring-System-2', 'didactum-monitoring-system-2.xml', 'baz') do
    it { should_not exist }
  end
end
