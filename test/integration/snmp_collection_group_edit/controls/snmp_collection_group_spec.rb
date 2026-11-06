# frozen_string_literal: true
require 'json'

control 'snmp_collection_group' do
  # On OpenNMS 36 the datacollection configuration is stored in the
  # database and served by the v2 REST API. Declared exclude filters and
  # systemDef-only restrictions of an include are not persisted there (a
  # filtered include is materialized by the server into a synthetic
  # __inline_<profile> source), so the assertions that pin the declared
  # form check the persisted result instead on v36
  v36 =
    begin
      inspec.http('http://localhost:8980/opennms/api/v2/datacollectionconf/profiles', auth: { user: 'admin', pass: 'admin' }).status == 200
    rescue StandardError
      false
    end

  describe snmp_collection_group('wibble-wobble', 'wibble-wobble.xml', 'baz') do
    it { should exist }
    its('system_def') { should eq 'Wibble' }
    its('exclude_filters') { should eq [] }
  end

  describe snmp_collection_group('apache2', 'apache2.xml', 'baz') do
    it { should exist }
    it 'restricts collection to the declared systemDef' do
      skip 'on OpenNMS 36 an include without exclude filters is persisted as a plain reference and the systemDef restriction is not kept' if v36
      expect(snmp_collection_group('apache2', 'apache2.xml', 'baz').system_def).to eq('nonsense')
    end
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

  if v36
    # the declared exclude filters of the Zeus include are applied at
    # upload time: the server materializes the surviving part of the Zeus
    # source into the synthetic __inline_default source, which the default
    # profile references instead of the plain Zeus reference; the filter
    # values themselves are not persisted
    describe 'Zeus include on the default profile (OpenNMS 36 materialized form)' do
      it 'is referenced via the materialized inline source, not as a plain reference' do
        response = inspec.http('http://localhost:8980/opennms/api/v2/datacollectionconf/profiles', auth: { user: 'admin', pass: 'admin' })
        row = JSON.parse(response.body).find { |p| p['name'] == 'default' }
        refs = row['sourceNames']
        refs = JSON.parse(refs) if refs.is_a?(String)
        expect(refs).to include('__inline_default')
        expect(refs).not_to include('Zeus')
      end

      it 'excludes every Zeus systemDef from the inline source' do
        ids = JSON.parse(inspec.http('http://localhost:8980/opennms/api/v2/datacollectionconf/collectsources/names-and-ids', auth: { user: 'admin', pass: 'admin' }).body)
        entry = ids.find { |s| s['name'] == '__inline_default' }
        expect(entry).not_to be_nil
        xml = inspec.http("http://localhost:8980/opennms/api/v2/datacollectionconf/collectsources/#{entry['id']}/download?format=xml", auth: { user: 'admin', pass: 'admin' }).body
        expect(xml).not_to include('<systemDef')
      end
    end
  else
    describe snmp_collection_group('Zeus', 'zeus.xml', 'default') do
      it { should exist }
      its('exclude_filters') { should eq [ '^.*$', '^.*+$' ] }
    end
  end

  describe snmp_collection_group('Didactum-Monitoring-System-2', 'didactum-monitoring-system-2.xml', 'baz') do
    it { should_not exist }
  end
end
