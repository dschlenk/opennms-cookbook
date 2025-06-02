# Defines a collection in $ONMS_HOME/etc/wsman-datacollection-config.xml.
# Will be used by any packages in $ONMS_HOME/etc/collectd-configuration.xml
# that have a WS-Man service with this collection name as the collection
# parameter value. You can use the wsman_collection_service LWRP to create
# that service, the collection_package LWRP to define the package and the
# wsman_group LWRP to define the data to collect in this wsman_collection.
use 'partial/_collection'

unified_mode true

include Opennms::Cookbook::Collection::WsmanCollectionTemplate

property :include_system_definitions, [String, true, false], callbacks: {
  'should be a string equalling \'true\' or \'false\' or `true` or `false`' => lambda { |p|
    (p.is_a?(String) && p.eql?('true') || p.eql?('false')) || true.eql?(p) || false.eql?(p)
  },
}
property :include_system_definition, Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}

load_current_value do |new_resource|
  r = wsman_resource("#{onms_etc}/wsman-datacollection-config.xml")
  if r.nil?
    ro_wsman_resource_init("#{onms_etc}/wsman-datacollection-config.xml")
    r = ro_wsman_resource("#{onms_etc}/wsman-datacollection-config.xml")
  end
  collection = r.variables[:collections][new_resource.collection]
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
  include_system_definitions collection.include_system_definitions
  include_system_definition collection.include_system_definition
end

action_class do
  include Opennms::Cookbook::Collection::WsmanCollectionTemplate
end

action :create do
  converge_if_changed do
    wsman_resource_init("#{onms_etc}/wsman-datacollection-config.xml")
    collection = wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections][new_resource.collection]
    if collection.nil?
      resource_properties = %i(name rrd_step rras include_system_definitions include_system_definition).map { |p| [p, new_resource.send(p)] }.to_h.compact
      collection = Opennms::Cookbook::Collection::WsmanCollection.new(**resource_properties)
      wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections][new_resource.collection] = collection
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  wsman_resource_init("#{onms_etc}/wsman-datacollection-config.xml")
  collection = wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections][new_resource.collection]
  run_action(:create) if collection.nil?
end

action :update do
  converge_if_changed(:rrd_step, :rras, :include_system_definitions, :include_system_definition) do
    wsman_resource_init("#{onms_etc}/wsman-datacollection-config.xml")
    collection = wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections][new_resource.collection]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras, include_system_definitions: new_resource.include_system_definitions, include_system_definition: new_resource.include_system_definition)
  end
end

action :delete do
  wsman_resource_init("#{onms_etc}/wsman-datacollection-config.xml")
  collection = wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections][new_resource.collection]
  unless collection.nil?
    converge_by("Removing wsman_collection #{new_resource.collection}") do
      wsman_resource("#{onms_etc}/wsman-datacollection-config.xml").variables[:collections].delete(new_resource.collection)
    end
  end
end
