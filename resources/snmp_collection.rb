unified_mode true
use 'partial/_collection'

include Opennms::Cookbook::Collection::SnmpCollectionTemplate

# no default: deprecated in OpenNMS
property :max_vars_per_pdu, Integer
# defaults to 'select' in create
property :snmp_stor_flag, String, equal_to: %w(all select primary)
property :include_collections, Array, callbacks: {
  'should be an array of hashes with keywords :data_collection_group (string, required), :exclude_filters (array of strings, optional), :system_def (string, optional)' => lambda { |p|
    !p.any? do |h|
      !h[:data_collection_group].is_a?(String) ||
        (h.key?(:exclude_filters) &&
         !h[:exclude_filters].is_a?(Array) ||
         (h.is_a?(Array) &&
         h[:exclude_filters].any? do |a|
           !a.is_a?(String)
         end
         )) ||
        (h.key?(:system_def) &&
         !h[:system_def].is_a?(String))
    end
  },
}

load_current_value do |new_resource|
  r = snmp_resource
  collection = r.variables[:collections][new_resource.collection] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collections = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'snmp').collections
    collection = collections[new_resource.collection]
  end
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
  begin
    max_vars_per_pdu Integer(collection.max_vars_per_pdu)
  rescue
    nil
  end
  snmp_stor_flag collection.snmp_stor_flag
  include_collections collection.include_collections
end

action_class do
  include Opennms::Cookbook::Collection::SnmpCollectionTemplate
end

action :create do
  converge_if_changed do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.collection]
    if collection.nil?
      resource_properties = %i(name rrd_step rras max_vars_per_pdu snmp_stor_flag include_collections).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:snmp_stor_flag] = 'select' if resource_properties[:snmp_stor_flag].nil?
      collection = Opennms::Cookbook::Collection::SnmpCollection.new(**resource_properties)
      snmp_resource.variables[:collections][new_resource.collection] = collection
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  snmp_resource_init
  collection = snmp_resource.variables[:collections][new_resource.collection]
  run_action(:create) if collection.nil?
end

action :update do
  converge_if_changed(:rrd_step, :rras, :max_vars_per_pdu, :snmp_stor_flag, :include_collections) do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.collection]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras, max_vars_per_pdu: new_resource.max_vars_per_pdu, snmp_stor_flag: new_resource.snmp_stor_flag, include_collections: new_resource.include_collections)
  end
end

action :delete do
  snmp_resource_init
  collection = snmp_resource.variables[:collections][new_resource.collection]
  unless collection.nil?
    converge_by("Removing snmp_collection #{new_resource.collection}") do
      snmp_resource.variables[:collections].delete(new_resource.collection)
    end
  end
end
