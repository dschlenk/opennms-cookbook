include Opennms::Cookbook::Collection::SnmpCollectionTemplate
include Opennms::Cookbook::Collection::DatacollectionV36Template
include Opennms::Rbac
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
  if datacollection_v36?
    at_name = dc_v36_file_at_name(new_resource.file)
    unless dc_v36_group_attached?(new_resource.collection_name, new_resource.group_name, file_at_name: at_name, system_def: new_resource.system_def)
      current_value_does_not_exist!
    end
    # the declared form of a filtered include is not persisted by the
    # server, so exclude_filters is always nil in the current value and a
    # declared filter is re-asserted (re-materialized) on every converge
    system_def new_resource.system_def
    exclude_filters nil
  else
    r = snmp_resource
    if r.nil?
      ro_snmp_resource_init
      r = ro_snmp_resource
    end
    collection = r.variables[:collections][new_resource.collection_name] unless r.nil?
    current_value_does_not_exist! if collection.nil?
    gn = new_resource.group_name
    group = collection.include_collection(data_collection_group: gn)
    current_value_does_not_exist! if group.nil?
    system_def group[:system_def]
    exclude_filters group[:exclude_filters]
  end
end

action_class do
  include Opennms::Cookbook::Collection::SnmpCollectionTemplate
  include Opennms::Cookbook::Collection::DatacollectionV36Template
  include Opennms::Rbac
  include Opennms::XmlHelper
end

action :create do
  unless new_resource.file.nil?
    if datacollection_v36?
      # Horizon 36 no longer ships the etc/datacollection directory; the
      # file is only seed material for the database-backed collection source
      declare_resource(:directory, "#{onms_etc}/datacollection") do
        owner node['opennms']['username']
        group node['opennms']['groupname']
        mode '0755'
      end
    end
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

  if datacollection_v36?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.file)
    form = dc_v36_group_attach_form(new_resource.collection_name, new_resource.group_name, file_at_name: dc_v36_file_at_name(new_resource.file), system_def: new_resource.system_def)
    if form.nil?
      converge_by("Adding #{new_resource.group_name} to collection #{new_resource.collection_name}") do
        dc_v36_source_file_seed(canonical, new_resource.file)
        dc_v36_group_include_set(new_resource.collection_name, canonical, { data_collection_group: canonical, exclude_filters: new_resource.exclude_filters, system_def: new_resource.system_def })
      end
    else
      run_action(:update)
    end
  else
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
end

action :create_if_missing do
  if datacollection_v36?
    at_name = dc_v36_file_at_name(new_resource.file)
    unless dc_v36_group_attached?(new_resource.collection_name, new_resource.group_name, file_at_name: at_name, system_def: new_resource.system_def)
      run_action(:create)
    end
  else
    snmp_resource_init
    collection = snmp_resource.variables[:collections][new_resource.collection_name]
    raise Chef::Exceptions::ResourceNotFound, "Collection '#{new_resource.collection_name}' not found." if collection.nil?
    gn = new_resource.group_name
    group = collection.include_collection(data_collection_group: gn)
    run_action(:create) if group.nil?
  end
end

action :update do
  unless new_resource.file.nil?
    if datacollection_v36?
      # Horizon 36 no longer ships the etc/datacollection directory; the
      # file is only seed material for the database-backed collection source
      declare_resource(:directory, "#{onms_etc}/datacollection") do
        owner node['opennms']['username']
        group node['opennms']['groupname']
        mode '0755'
      end
    end
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
  if datacollection_v36?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.file)
    form = dc_v36_group_attach_form(new_resource.collection_name, new_resource.group_name, file_at_name: dc_v36_file_at_name(new_resource.file), system_def: new_resource.system_def)
    raise Chef::Exceptions::CurrentValueDoesNotExist, "Group '#{new_resource.group_name}' not found in collection '#{new_resource.collection_name}'." if form.nil?
    converge_if_changed(:exclude_filters, :system_def) do
      dc_v36_source_file_seed(canonical, new_resource.file)
      dc_v36_group_include_set(new_resource.collection_name, canonical, { data_collection_group: canonical, exclude_filters: new_resource.exclude_filters, system_def: new_resource.system_def }, replace_inline: form.eql?(:inline))
    end
  else
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
end

action :delete do
  if datacollection_v36?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.file)
    form = dc_v36_group_attach_form(new_resource.collection_name, new_resource.group_name, file_at_name: dc_v36_file_at_name(new_resource.file))
    unless form.nil?
      converge_by("Removing #{new_resource.group_name} from collection #{new_resource.collection_name}") do
        dc_v36_group_include_remove(new_resource.collection_name, canonical, remove_inline: form.eql?(:inline))
        dc_v36_source_delete(canonical)
        dc_v36_cleanup_inline_source(new_resource.collection_name)
      end
    end
    unless new_resource.file.nil?
      declare_resource(:file, "#{onms_etc}/datacollection/#{new_resource.file}") do
        action :nothing
        delayed_action :delete
      end
    end
  else
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
end
