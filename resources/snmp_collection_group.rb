include Opennms::Cookbook::Collection::SnmpCollectionTemplate
include Opennms::XmlHelper

unified_mode true
property :group_name, String, name_property: true, identity: true
property :collection_name, String, default: 'default', identity: true
property :file, String, desired_state: false
# set to the URL of your data collection file if not stored in your cookbook
property :source, String, default: 'cookbook_file', desired_state: false
property :system_def, String
property :exclude_filters, Array, callbacks: {
  'should contain an array of strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}

load_current_value do |new_resource|
  r = snmp_resource
  collection = r.variables[:collections][new_resource.collection_name] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collections = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'snmp').collections
    collection = collections[new_resource.collection_name]
  end
  current_value_does_not_exist! if collection.nil?
  gn = new_resource.group_name
  group = collection.include_collection(data_collection_group: gn)
  current_value_does_not_exist! if group.nil?
  system_def group[:system_def]
  exclude_filters group[:exclude_filters]
end

action_class do
  include Opennms::Cookbook::Collection::SnmpCollectionTemplate
  include Opennms::XmlHelper
end

action :create do
  unless new_resource.file.nil?
    if 'cookbook_file'.eql?(new_resource.source)
      rt = :cookbook_file
      s = new_resource.file
    else
      rt = :remote_file
      s = new_resource.source
    end
    declare_resource(rt, "#{onms_etc}/datacollection/#{new_resource.file}") do
      source s
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0664'
    end
  end

  converge_if_changed do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.collection_name]
    if collection.nil?
      raise Chef::Exceptions::ResourceNotFound, "Collection '#{new_resource.collection_name}' not found."
    end
    gn = new_resource.group_name
    group = collection.include_collection(data_collection_group: gn)
    if group.nil?
      group = { data_collection_group: gn, exclude_filters: new_resource.exclude_filters, system_def: new_resource.system_def }
      collection.include_collections.push(group)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  snmp_resource_init
  collection = snmp_resource.variables[:collections][new_resource.collection_name]
  if collection.nil?
    Chef::Log.info("Collection '#{new_resource.collection_name}' not found, creating it.")
    collection = { new_resource.collection_name => { include_collections: [] } }
    snmp_resource.variables[:collections][new_resource.collection_name] = collection
  end
  gn = new_resource.group_name
  group = collection.include_collection(data_collection_group: gn)
  if group.nil?
    group = { data_collection_group: gn, exclude_filters: new_resource.exclude_filters, system_def: new_resource.system_def }
    collection.include_collections.push(group)
  else
    Chef::Log.info("Group '#{gn}' already exists in collection '#{new_resource.collection_name}'.")
  end
end

action :update do
  unless new_resource.file.nil?
    if 'cookbook_file'.eql?(new_resource.source)
      rt = :cookbook_file
      s = new_resource.file
    else
      rt = :remote_file
      s = new_resource.source
    end
    declare_resource(rt, "#{onms_etc}/datacollection/#{new_resource.file}") do
      source s
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0664'
    end
  end
  converge_if_changed(:exclude_filters, :system_def) do
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.collection_name]
    gn = new_resource.group_name
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    group = collection.include_collection(data_collection_group: gn)
    group[:exclude_filters] = new_resource.exclude_filters unless new_resource.exclude_filters.nil?
    group[:system_def] = new_resource.system_def unless new_resource.system_def.nil?
  end
end

action :delete do
  snmp_resource_init
  collection = snmp_resource.variables[:collections][new_resource.collection_name]
  gn = new_resource.group_name
  group = collection.include_collection(data_collection_group: gn) unless collection.nil?
  unless group.nil?
    converge_by("Removing #{gn}") do
      collection.include_collections.delete_if { |ic| ic[:data_collection_group].eql?(gn) }
    end
  end
  unless new_resource.file.nil?
    declare_resource(:file, "#{onms_etc}/datacollection/#{new_resource.file}") do
      action :nothing
      delayed_action :delete
      notifies :create, "template[#{onms_etc}/datacollection-config.xml]", :immediately
    end
  end
end
