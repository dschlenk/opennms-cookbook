# use default UEI
opennms_send_event 'restart notifd' do
  parameters ['daemonName Threshd', 'configFile thresholds.xml']
end

opennms_send_event 'reread snmp config' do
  uei 'uei.opennms.org/internal/configureSNMP'
end
