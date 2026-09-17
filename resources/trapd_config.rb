include Opennms::Cookbook::Trapd::ConfigTemplate
unified_mode true

provides :opennms_trapd_config

property :batch_interval, Integer, default: 500
property :batch_size, Integer, default: 1000
property :include_raw_message, [true, false], default: false
property :new_suspect_on_trap, [true, false], default: false
property :queue_size, Integer, default: 10000
property :snmp_trap_address, String, default: '*'
property :snmp_trap_port, Integer, default: 10162
property :threads, Integer, default: 0
property :use_address_from_varbind, [true, false]

action_class do
  include Opennms::Cookbook::Trapd::ConfigTemplate
end

load_current_value do
  r = trapd_resource
  if r.nil?
    ro_trapd_resource_init
    r = ro_trapd_resource
  end
  config = config_from_resource(r)
  %i(snmp_trap_address snmp_trap_port new_suspect_on_trap include_raw_message threads queue_size batch_size batch_interval use_address_from_varbind).each do |p|
    if %i(snmp_trap_port threads queue_size batch_size batch_interval).include?(p)
      send(p, config.send(p).to_i)
    elsif %i(new_suspect_on_trap include_raw_message use_address_from_varbind).include?(p)
      send(p, config.send(p) == 'true')
    else
      send(p, config.send(p))
    end
  end
end

action :create do
  converge_if_changed do
    trapd_resource_init
    cfg = config_from_resource(trapd_resource)
    cfg.snmp_trap_address = new_resource.snmp_trap_address
    cfg.snmp_trap_port = new_resource.snmp_trap_port
    cfg.new_suspect_on_trap = new_resource.new_suspect_on_trap
    cfg.include_raw_message = new_resource.include_raw_message
    cfg.threads = new_resource.threads
    cfg.queue_size = new_resource.queue_size
    cfg.batch_size = new_resource.batch_size
    cfg.batch_interval = new_resource.batch_interval
    cfg.use_address_from_varbind = new_resource.use_address_from_varbind unless new_resource.use_address_from_varbind.nil?
  end
end
