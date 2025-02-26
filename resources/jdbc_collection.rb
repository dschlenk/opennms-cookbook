unified_mode true
use 'partial/_collection'

include Opennms::Cookbook::Collection::JdbcCollectionTemplate

load_current_value do |new_resource|
  r = jdbc_resource
  collection = r.variables[:collections][new_resource.collection] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/jdbc-datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'jdbc').collections[new_resource.collection]
  end
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
end

action_class do
  include Opennms::Cookbook::Collection::JdbcCollectionTemplate
end

action :create do
  converge_if_changed do
    jdbc_resource_init
    collection = jdbc_resource.variables[:collections][new_resource.collection]
    if collection.nil?
      resource_properties = %i(name rrd_step rras).map { |p| [p, new_resource.send(p)] }.to_h.compact
      collection = Opennms::Cookbook::Collection::JdbcCollection.new(**resource_properties)
      jdbc_resource.variables[:collections][new_resource.collection] = collection
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  jdbc_resource_init
  collection = jdbc_resource.variables[:collections][new_resource.collection]
  run_action(:create) if collection.nil?
end

action :update do
  converge_if_changed(:rrd_step, :rras) do
    jdbc_resource_init
    collection = jdbc_resource.variables[:collections][new_resource.collection]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras)
  end
end

action :delete do
  jdbc_resource_init
  collection = jdbc_resource.variables[:collections][new_resource.collection]
  unless collection.nil?
    converge_by("Removing jdbc_collection #{new_resource.collection}") do
      jdbc_resource.variables[:collections].delete(new_resource.collection)
    end
  end
end
