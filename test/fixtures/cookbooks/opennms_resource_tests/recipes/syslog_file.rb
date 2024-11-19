opennms_syslog_file 'syslog-file1.xml' do
  position 'top'
end

opennms_syslog_file 'syslog-file2.xml' do
  position 'bottom'
end

opennms_syslog_file 'NetgearProsafeSmartSwitch.syslog.xml' do
  action :delete
end
