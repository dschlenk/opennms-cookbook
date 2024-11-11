opennms_system_def 'Cisco Routers' do
  file_name 'cisco.xml'
  groups %w(mib2-tcp mib2-powerethernet)
  action :add
end
opennms_system_def 'Cisco ASA5510sy' do
  file_name 'cisco.xml'
  groups %w(cisco-pix cisco-memory)
  action :remove
end
# new def in a new file with a sysoid and the seemingly unimplemented IpList elements
opennms_system_def 'foo' do
  file_name 'foo.xml'
  sysoid '.1.3.6.1.4.1.9.1.668'
  ip_addrs ['127.0.0.1', '127.0.0.2']
  ip_addr_masks ['255.255.255.0']
  groups %w(mib2-tcp mib2-powerethernet cisco-pix cisco-memory)
  action :create
end
# new def in an existing file with a sysoid_mask
opennms_system_def 'foo' do
  file_name 'cisco.xml'
  sysoid_mask '.1.3.6.1.4.1.9.1.%'
  groups %w(mib2-tcp mib2-powerethernet cisco-pix cisco-memory)
  action :create
end
# remove OOTB systemDef
opennms_system_def 'Cisco PIX 506' do
  file_name 'cisco.xml'
  action :delete
end
