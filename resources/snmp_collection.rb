unified_mode true
use 'partial/_collection'

include Opennms::Cookbook::Collection::SnmpCollectionTemplate

# no default: deprecated in OpenNMS
property :max_vars_per_pdu, Integer
# defaults to 'select' in create
property :snmp_stor_flag, String, equal_to: %w(all select primary)

load_current_value do |new_resource|
  r = snmp_resource
  collection = r.variables[:collections[new_resource.collection]] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/snmp-datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'snmp').collections[new_resource.collection]
  end
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
  max_vars_per_pdu collection.max_vars_per_pdu
  snmp_stor_flag collection.snmp_stor_flag
end

action_class do
  include Opennms::Cookbook::Collection::SnmpCollectionTemplate
end

action :create do
  converge_if_changed do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.name]
    if collection.nil?
      resource_properties = %i(name rrd_step rras max_vars_per_pdu snmp_stor_flag).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:snmp_stor_flag] = 'select' if resource_properties[:snmp_stor_flag].nil?
      collection = Opennms::Cookbook::Collection::SnmpCollection.new(**resource_properties)
      snmp_resource.variables[:collections][new_resource.name] = collection
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed(:rrd_step, :rras, :max_vars_per_pdu, :snmp_stor_flag) do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.name]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras, max_vars_per_pdu: new_resource.max_vars_per_pdu, snmp_stor_flag: new_resource.snmp_stor_flag)
  end
end

action :delete do
  snmp_resource_init
  collection = snmp_resource.variables[:collections][new_resource.name]
  unless collection.nil?
    converge_by("Removing snmp_collection #{new_resource.name}") do
      snmp_resource.variables[:collections].delete(new_resource.name)
    end
  end
end
