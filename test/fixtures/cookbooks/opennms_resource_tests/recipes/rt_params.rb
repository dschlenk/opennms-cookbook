opennms_system_def 'Net-SNMP' do
  file_name 'netsnmp.xml'
  groups ['mib2-host-resources-storage']
end

opennms_system_def 'Enterprise' do
  file_name 'mib2.xml'
  groups ['mib2-interfaces']
end
