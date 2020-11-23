# frozen_string_literal: true
log 'Start OpenNMS to perform ReST operations.' do
  notifies :start, 'service[opennms]', :immediately
end
opennms_foreign_source 'localhost'
opennms_import 'localhost' do
  foreign_source_name 'localhost'
  sync_import false
end

iface_node_foreign_id = '1'
opennms_import_node 'localhost' do
  foreign_source_name 'localhost'
  foreign_id iface_node_foreign_id
  sync_import false
end

%w(127.0.0.1 10.0.2.15).each do |ip|
  opennms_import_node_interface ip do
    foreign_source_name 'localhost'
    foreign_id iface_node_foreign_id
    managed true
    snmp_primary 'P'
    sync_import false
  end
  # all options
  opennms_import_node_interface_service 'SNMP' do
    foreign_source_name 'localhost'
    foreign_id iface_node_foreign_id
    ip_addr ip
    sync_import false
  end
  opennms_import_node_interface_service 'ICMP' do
    foreign_source_name 'localhost'
    foreign_id iface_node_foreign_id
    ip_addr ip
    sync_import false
  end
end

# best practice is to do all your edits and sync at the end.
# you might run into inconsistencies if you sync at each
# step, depending on how fast your hardware is due to the
# nature of how provisiond works
log 'sync localhost requisition' do
  notifies :sync, 'opennms_import[localhost]', :immediately
end
