unified_mode true

provides :opennms_trapd_config

property :batch_interval, Integer
property :batch_size, Integer
property :include_raw_message, [true, false]
property :new_suspect_on_trap, [true, false]
property :queue_size, Integer
property :snmp_trap_address, String
property :snmp_trap_port, Integer
property :threads, Integer
property :use_address_from_varbind, [true, false]

load_current_value do
  cfg = Opennms::Trapd::TrapdConfig.instance_for(node)

  batch_interval cfg.current['batchInterval']
  batch_size cfg.current['batchSize']
  include_raw_message cfg.current['includeRawMessage']
  new_suspect_on_trap cfg.current['newSuspectOnTrap']
  queue_size cfg.current['queueSize']
  snmp_trap_address cfg.current['snmpTrapAddress']
  snmp_trap_port cfg.current['snmpTrapPort']
  threads cfg.current['threads']
  use_address_from_varbind cfg.current['useAddressFromVarbind']
end

action :create do
  converge_if_changed do
    cfg = Opennms::Trapd::TrapdConfig.instance_for(node)

    cfg.batchInterval = new_resource.batch_interval unless new_resource.batch_interval.nil?
    cfg.batchSize = new_resource.batch_size unless new_resource.batch_size.nil?
    cfg.includeRawMessage = new_resource.include_raw_message unless new_resource.include_raw_message.nil?
    cfg.newSuspectOnTrap = new_resource.new_suspect_on_trap unless new_resource.new_suspect_on_trap.nil?
    cfg.queueSize = new_resource.queue_size unless new_resource.queue_size.nil?
    cfg.snmpTrapAddress = new_resource.snmp_trap_address unless new_resource.snmp_trap_address.nil?
    cfg.snmpTrapPort = new_resource.snmp_trap_port unless new_resource.snmp_trap_port.nil?
    cfg.threads = new_resource.threads unless new_resource.threads.nil?
    cfg.useAddressFromVarbind = new_resource.use_address_from_varbind unless new_resource.use_address_from_varbind.nil?

    cfg.update(self)
  end
end
