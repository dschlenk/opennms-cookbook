# Defines a collection in $ONMS_HOME/etc/jmx-datacollection-config.xml.
# Will be used by any packages in $ONMS_HOME/etc/collectd-configuration.xml
# that have a JMX service with this collection name as the collection
# parameter value. You can use the jmx_collection_service LWRP to create
# that service, the collection_package LWRP to define the package and the
# jmx_mbean LWRP to define the queries in this jmx_collection.
use 'partial/_collection'

unified_mode true

include Opennms::Cookbook::Collection::JmxCollectionTemplate

load_current_value do |new_resource|
  r = jmx_resource
  if r.nil?
    ro_jmx_resource_init
    r = ro_jmx_resource
  end
  collection = r.variables[:collections][new_resource.collection]
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
end

action_class do
  include Opennms::Cookbook::Collection::JmxCollectionTemplate
end

action :create do
  converge_if_changed do
    jmx_resource_init
    collection = jmx_resource.variables[:collections][new_resource.collection]
    if collection.nil?
      resource_properties = %i(name rrd_step rras).map { |p| [p, new_resource.send(p)] }.to_h.compact
      collection = Opennms::Cookbook::Collection::JmxCollection.new(**resource_properties)
      jmx_resource.variables[:collections][new_resource.collection] = collection
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed(:rrd_step, :rras) do
    jmx_resource_init
    collection = jmx_resource.variables[:collections][new_resource.collection]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras)
  end
end

action :delete do
  jmx_resource_init
  collection = jmx_resource.variables[:collections][new_resource.collection]
  unless collection.nil?
    converge_by("Removing jmx_collection #{new_resource.collection}") do
      jmx_resource.variables[:collections].delete(new_resource.collection)
    end
  end
end
