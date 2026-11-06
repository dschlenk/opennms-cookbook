include Opennms::XmlHelper
include Opennms::Cookbook::Collection::ResourceTypeTemplate
include Opennms::Cookbook::Collection::GroupResourceTypeTemplate
include Opennms::Cookbook::Collection::DatacollectionV36Template
include Opennms::Rbac

unified_mode true

property :type_name, String, name_property: true
# use this property if you want the resource type to be in a datacollection-group named <group_name> in a file named <group_name>.xml group under `$OPENNMS_HOME/etc/datacollection`
property :group_name, String, identity: true, callbacks: {
  'should not be the empty string or start with a \'\.\' or \'\/\' character' => lambda { |p|
    !''.eql?(p) && !p.start_with?('.') && !p.start_with?('/')
  },
}
# to create/update a resource type in a group and the name of the file differs from the name of the group, use both `group_name` and `group_file_name` for best results
property :group_file_name, String, identity: true
# ignored when `group_name` is set; otherwise used as the name of the file in which to manage the resource type under `$OPENNMS_HOME/etc/resource-types.d/`
property :file_name, String, identity: true, callbacks: {
  'should not be the empty string or start with a \'\.\' or \'\/\' character' => lambda { |p|
    !''.eql?(p) && !p.start_with?('.') && !p.start_with?('/') && p.end_with?('.xml')
  },
}
property :label, String
# defaults to '${resource} (index:${index})' on :create
property :resource_label, String
# defaults to 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy' on :create
property :persistence_selector_strategy, String
# Can be an array of single key/value hashes with quoted string key names
# or a single hash of quoted string key pairs if no keys need to be repeated
property :persistence_selector_strategy_params, [Hash, Array], callbacks: {
  'should be a Hash of string key value pairs or an Array of hashes (when multiple params with the same key needed)' => lambda { |p|
    (p.is_a?(Hash) && !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }) ||
      (p.is_a?(Array) && !p.any? { |a| !a.is_a?(Hash) || a.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } })
  },
}
# defaults to 'org.opennms.netmgt.collection.support.IndexStorageStrategy' on :create
property :storage_strategy, String
# Must be an array of single key/value hashes with quoted string key names.
property :storage_strategy_params, [Hash, Array], callbacks: {
  'should be a Hash of string key value pairs or an Array of hashes (when multiple params with the same key needed)' => lambda { |p|
    (p.is_a?(Hash) && !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }) ||
      (p.is_a?(Array) && !p.any? { |a| !a.is_a?(Hash) || a.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } })
  },
}

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Collection::ResourceTypeTemplate
  include Opennms::Cookbook::Collection::GroupResourceTypeTemplate
  include Opennms::Cookbook::Collection::SnmpCollectionTemplate
  include Opennms::Cookbook::Collection::DatacollectionV36Template
  include Opennms::Rbac
end

load_current_value do |new_resource|
  if new_resource.group_name.nil? && !new_resource.file_name.nil?
    file = "#{onms_etc}/resource-types.d/#{new_resource.file_name}"
  elsif !new_resource.group_name.nil?
    gfn = new_resource.group_file_name.nil? ? "#{new_resource.group_name}.xml" : new_resource.group_file_name
    file = "#{onms_etc}/datacollection/#{gfn}"
  end
  raise Chef::Exceptions::ValidationFailed, 'Either `group_name` or `file_name` must be defined in `opennms_resource_type`' if file.nil?
  if datacollection_v36? && !new_resource.group_name.nil?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.group_file_name)
    rt = dc_v36_resource_type(canonical, new_resource.type_name)
  else
    current_value_does_not_exist! unless ::File.exist?(file)
    if !new_resource.group_name.nil?
      r = rtgroup_resource(file)
      ro_rtgroup_resource_init(file) if r.nil?
      r = ro_rtgroup_resource(file) if r.nil?
    else
      r = rt_resource(file)
      ro_rt_resource_init(file) if r.nil?
      r = ro_rt_resource(file) if r.nil?
    end
    rt = r.variables[:config].resource_type(name: new_resource.type_name)
  end
  current_value_does_not_exist! if rt.nil?
  %i(label resource_label).each do |p|
    send(p, rt[p])
  end
  persistence_selector_strategy rt[:persistence_selector_strategy][:class]
  # new_resource might be an array or a hash. current value is always an array
  # so we have to convert the new_resource hash to array to compare them accurately
  # but we can only do that if the current value array does not contain more than one hash with the same key
  ssp = rt[:persistence_selector_strategy][:parameters]
  if new_resource.persistence_selector_strategy_params.is_a?(Hash) && rt[:persistence_selector_strategy][:parameters].is_a?(Array)
    keys = []
    rt[:persistence_selector_strategy][:parameters].each do |h|
      keys.push h.keys[0]
    end
    if keys.size == keys.uniq.size
      ssp = {}
      rt[:persistence_selector_strategy][:parameters].each do |h|
        h.each do |k, v|
          ssp[k] = v
        end
      end
    end
  end
  persistence_selector_strategy_params ssp
  storage_strategy rt[:storage_strategy][:class]
  stsp = rt[:storage_strategy][:parameters]
  if new_resource.storage_strategy_params.is_a?(Hash) && rt[:storage_strategy][:class].is_a?(Array)
    keys = []
    rt[:storage_strategy][:parameters].each do |h|
      keys.push h.keys[0]
    end
    if keys.size == keys.uniq.size
      stsp = {}
      rt[:storage_strategy][:parameters].each do |h|
        h.each do |k, v|
          stsp[k] = v
        end
      end
    end
  end
  storage_strategy_params stsp
end

action :create do
  if datacollection_v36? && !new_resource.group_name.nil?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.group_file_name)
    if dc_v36_resource_type(canonical, new_resource.type_name).nil?
      raise Chef::Exceptions::ValidationFailed, '`label` is a required property for action `:create`' if new_resource.label.nil?
      converge_by("Adding #{new_resource.type_name} to #{new_resource.group_name}") do
        dc_v36_profile_attach('default', canonical)
        dc_v36_resource_type_set(canonical, { name: new_resource.type_name,
                                              label: new_resource.label,
                                              resource_label: new_resource.resource_label,
                                              persistence_selector_strategy: { class: new_resource.persistence_selector_strategy || 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy',
                                                                                parameters: new_resource.persistence_selector_strategy_params },
                                              storage_strategy: { class: new_resource.storage_strategy || 'org.opennms.netmgt.collection.support.IndexStorageStrategy',
                                                                  parameters: new_resource.storage_strategy_params } })
      end
    else
      run_action(:update)
    end
  else
    # on Horizon 36 this branch is only reached for the file_name flow,
    # which does not touch the collection config (and the
    # datacollection-config.xml file does not exist)
    snmp_resource_init unless datacollection_v36?
    unless new_resource.group_name.nil?
      dc = snmp_resource.variables[:collections]['default']
      ics = dc.include_collections.select { |ic| ic[:data_collection_group].eql?(new_resource.group_name) } unless dc.nil?
      if ics.nil? || ics.empty?
        snmp_resource.variables[:collections]['default'].include_collections.push({ data_collection_group: new_resource.group_name })
      end
    end
    converge_if_changed do
      if new_resource.group_name.nil? && !new_resource.file_name.nil?
        file = "#{onms_etc}/resource-types.d/#{new_resource.file_name}"
      elsif !new_resource.group_name.nil?
        gfn = new_resource.group_file_name.nil? ? "#{new_resource.group_name}.xml" : new_resource.group_file_name
        file = "#{onms_etc}/datacollection/#{gfn}"
      end
      if !new_resource.group_name.nil?
        rtgroup_resource_init(file, new_resource.group_name)
        config = rtgroup_resource(file).variables[:config]
      else
        rt_resource_init(file)
        config = rt_resource(file).variables[:config]
      end
      rt = config.resource_type(name: new_resource.type_name)
      if rt.nil?
        raise Chef::Exceptions::ValidationFailed, '`label` is a required property for action `:create`' if new_resource.label.nil?
        rt = { name: new_resource.type_name, label: new_resource.label, resource_label: new_resource.resource_label, persistence_selector_strategy: { class: new_resource.persistence_selector_strategy || 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy', parameters: new_resource.persistence_selector_strategy_params }, storage_strategy: { class: new_resource.storage_strategy || 'org.opennms.netmgt.collection.support.IndexStorageStrategy', parameters: new_resource.storage_strategy_params } }
        config.resource_types.push(rt)
      else
        run_action(:update)
      end
    end
  end
end

action :create_if_missing do
  if datacollection_v36? && !new_resource.group_name.nil?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.group_file_name)
    run_action(:create) if dc_v36_resource_type(canonical, new_resource.type_name).nil?
  else
    # on Horizon 36 this branch is only reached for the file_name flow,
    # which does not touch the collection config
    snmp_resource_init unless datacollection_v36?
    if new_resource.group_name.nil? && !new_resource.file_name.nil?
      file = "#{onms_etc}/resource-types.d/#{new_resource.file_name}"
    elsif !new_resource.group_name.nil?
      gfn = new_resource.group_file_name.nil? ? "#{new_resource.group_name}.xml" : new_resource.group_file_name
      file = "#{onms_etc}/datacollection/#{gfn}"
    end
    if !new_resource.group_name.nil?
      rtgroup_resource_init(file, new_resource.group_name)
      config = rtgroup_resource(file).variables[:config]
    else
      rt_resource_init(file)
      config = rt_resource(file).variables[:config]
    end
    rt = config.resource_type(name: new_resource.type_name)
    run_action(:create) if rt.nil?
  end
end

action :update do
  if datacollection_v36? && !new_resource.group_name.nil?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.group_file_name)
    converge_if_changed do
      dc_v36_profile_attach('default', canonical)
      current = dc_v36_resource_type(canonical, new_resource.type_name)
      raise Chef::Exceptions::CurrentValueDoesNotExist, "No resourceType found named #{new_resource.type_name} in #{canonical}" if current.nil?
      # declared properties override the current values, undeclared ones
      # keep the current value so the rewritten element is unchanged apart
      # from the declared deltas
      rt = { name: new_resource.type_name,
             label: new_resource.label.nil? ? current[:label] : new_resource.label,
             resource_label: new_resource.resource_label.nil? ? current[:resource_label] : new_resource.resource_label,
             persistence_selector_strategy: { class: new_resource.persistence_selector_strategy.nil? ? current[:persistence_selector_strategy][:class] : new_resource.persistence_selector_strategy,
                                               parameters: new_resource.persistence_selector_strategy_params.nil? ? current[:persistence_selector_strategy][:parameters] : new_resource.persistence_selector_strategy_params },
             storage_strategy: { class: new_resource.storage_strategy.nil? ? current[:storage_strategy][:class] : new_resource.storage_strategy,
                                 parameters: new_resource.storage_strategy_params.nil? ? current[:storage_strategy][:parameters] : new_resource.storage_strategy_params } }
      dc_v36_resource_type_set(canonical, rt)
    end
  else
    # on Horizon 36 this branch is only reached for the file_name flow,
    # which does not touch the collection config
    snmp_resource_init unless datacollection_v36?
    unless new_resource.group_name.nil?
      dc = snmp_resource.variables[:collections]['default']
      ics = dc.include_collections.select { |ic| ic[:data_collection_group].eql?(new_resource.group_name) } unless dc.nil?
      if ics.nil? || ics.empty?
        snmp_resource.variables[:collections]['default'].include_collections.push({ data_collection_group: new_resource.group_name })
      end
    end
    converge_if_changed do
      if new_resource.group_name.nil? && !new_resource.file_name.nil?
        file = "#{onms_etc}/resource-types.d/#{new_resource.file_name}"
      elsif !new_resource.group_name.nil?
        gfn = new_resource.group_file_name.nil? ? "#{new_resource.group_name}.xml" : new_resource.group_file_name
        file = "#{onms_etc}/datacollection/#{gfn}"
      end
      if !new_resource.group_name.nil?
        rtgroup_resource_init(file, new_resource.group_name)
        config = rtgroup_resource(file).variables[:config]
      else
        rt_resource_init(file)
        config = rt_resource(file).variables[:config]
      end
      rt = config.resource_type(name: new_resource.type_name)
      raise Chef::Exceptions::CurrentValueDoesNotExist if rt.nil?
      config.resource_type_update(name: new_resource.type_name, label: new_resource.label, resource_label: new_resource.resource_label, persistence_selector_strategy: new_resource.persistence_selector_strategy, persistence_selector_strategy_params: new_resource.persistence_selector_strategy_params, storage_strategy: new_resource.storage_strategy, storage_strategy_params: new_resource.storage_strategy_params)
    end
  end
end

action :delete do
  if datacollection_v36? && !new_resource.group_name.nil?
    canonical = dc_v36_group_canonical(new_resource.group_name, new_resource.group_file_name)
    unless dc_v36_resource_type(canonical, new_resource.type_name).nil?
      converge_by("Removing #{new_resource.type_name} from #{canonical}") do
        dc_v36_resource_type_delete(canonical, new_resource.type_name)
      end
    end
  else
    if new_resource.group_name.nil? && !new_resource.file_name.nil?
      file = "#{onms_etc}/resource-types.d/#{new_resource.file_name}"
    elsif !new_resource.group_name.nil?
      gfn = new_resource.group_file_name.nil? ? "#{new_resource.group_name}.xml" : new_resource.group_file_name
      file = "#{onms_etc}/datacollection/#{gfn}"
    end
    if !new_resource.group_name.nil?
      rtgroup_resource_init(file, new_resource.group_name)
      config = rtgroup_resource(file).variables[:config]
    else
      rt_resource_init(file)
      config = rt_resource(file).variables[:config]
    end
    rt = config.resource_type(name: new_resource.type_name)
    unless rt.nil?
      converge_by "Removing #{new_resource.type_name} from #{file}" do
        config.resource_type_delete(name: new_resource.type_name)
      end
    end
  end
end
