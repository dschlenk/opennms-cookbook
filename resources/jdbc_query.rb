unified_mode true

include Opennms::XmlHelper
include Opennms::Cookbook::Collection::JdbcCollectionTemplate

property :query_name, String, name_property: true
property :collection_name, String, required: true, identity: true
property :if_type, String, required: true
property :recheck_interval, Integer, required: true
# the schema says resourceType is required, but it is not present in several examples in the default config
property :resource_type, String
property :instance_column, String
property :query_string, String, required: true
property :columns, Hash, default: {}, callbacks: {
  'should be a Hash where each key is a string that has a Hash value with required keys `alias` (string), `type` (string) and optional key `data-source-name` (string)' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(Hash) || !v.key?('alias') || !v['alias'].is_a?(String) || !v.key?('type') || !v['type'].is_a?(String) || (v.key?('data-source-name') && !v['data-source-name'].is_a?(String)) }
  },
}

load_current_value do |new_resource|
  r = jdbc_resource
  if r.nil?
    ro_jdbc_resource_init
    r = ro_jdbc_resource
  end
  collection = r.variables[:collections][new_resource.collection_name]
  current_value_does_not_exist! if collection.nil?
  query = collection.query(name: new_resource.query_name)
  current_value_does_not_exist! if query.nil?
  %i(if_type recheck_interval resource_type instance_column query_string columns).each do |p|
    send(p, query.send(p))
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Collection::JdbcCollectionTemplate
end

action :create do
  converge_if_changed do
    jdbc_resource_init
    collection = jdbc_resource.variables[:collections][new_resource.collection_name]
    raise Opennms::Cookbook::Collection::NoSuchCollection, "No JDBC collection named #{new_resource.collection_name}, cannot add jdbc_query to it." if collection.nil?
    query = collection.query(name: new_resource.query_name)
    if query.nil?
      resource_properties = %i(if_type recheck_interval resource_type instance_column query_string columns).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:name] = new_resource.query_name
      collection.queries.push(Opennms::Cookbook::Collection::JdbcQuery.new(**resource_properties))
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed(:if_type, :recheck_interval, :resource_type, :instance_column, :query_string, :columns) do
    jdbc_resource_init
    collection = jdbc_resource.variables[:collections][new_resource.collection_name]
    query = collection.query(name: new_resource.query_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist if query.nil?
    resource_properties = %i(if_type recheck_interval resource_type instance_column query_string columns).map { |p| [p, new_resource.send(p)] }.to_h.compact
    query.update(**resource_properties)
  end
end

action :delete do
  jdbc_resource_init
  collection = jdbc_resource.variables[:collections][new_resource.collection_name]
  query = collection.query(name: new_resource.query_name) unless collection.nil?
  unless query.nil?
    converge_by("Removing jdbc_query #{new_resource.query_name} from collection #{new_resource.collection_name}") do
      collection.queries.delete_if { |q| q.name.eql?(new_resource.query_name) }
    end
  end
end
