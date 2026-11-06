include Opennms::XmlHelper
include Opennms::Cookbook::Collection::ResourceTypeTemplate
include Opennms::Cookbook::Collection::GroupResourceTypeTemplate
include Opennms::Cookbook::Collection::DatacollectionV36Template
include Opennms::Rbac

unified_mode true

property :system_name, String, name_property: true
property :file_name, String, required: true, identity: true, callbacks: {
  'should not be the empty string or start with a \'\.\' or \'\/\' character and should end with .xml' => lambda { |p|
    !''.eql?(p) && !p.start_with?('.') && !p.start_with?('/') && p.end_with?('.xml')
  },
}
property :sysoid, String
property :sysoid_mask, String
# I am pretty sure this and the next property don't do anything
property :ip_addrs, Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  },
}
property :ip_addr_masks, Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  },
}
property :groups, kind_of: Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
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
  if datacollection_v36?
    # on OpenNMS 36 the system definitions live in the database collection
    # source named after the file; the file is not read or written
    source = dc_v36_source_for_file(new_resource.file_name)
    sd = dc_v36_system_def(source, new_resource.system_name)
  else
    file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
    current_value_does_not_exist! unless ::File.exist?(file)
    r = rtgroup_resource(file)
    if r.nil?
      ro_rtgroup_resource_init(file)
      r = ro_rtgroup_resource(file)
    end
    sd = r.variables[:config].system_def(name: new_resource.system_name)
  end
  current_value_does_not_exist! if sd.nil?
  %i(sysoid sysoid_mask ip_addrs ip_addr_masks).each do |p|
    if sd[p].nil?
      Chef::Log.debug("No property #{p} for system_def #{new_resource.system_name}")
    else
      send(p, sd[p])
    end
  end
  groups sd[:include_groups]
end

# adds any missing groups to existing systemDef
action :add do
  raise Chef::Exceptions::ValidationFailed, 'groups property is required when using :add action' if new_resource.groups.nil?
  if datacollection_v36?
    source = dc_v36_source_for_file(new_resource.file_name)
    sd = dc_v36_system_def(source, new_resource.system_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition' if sd.nil?
    current_groups = sd[:include_groups] || []
    combined = current_groups.dup
    new_resource.groups.each do |g|
      combined.push(g) unless combined.include?(g)
    end
    if combined.length > current_groups.length
      converge_by "Setting systemDef #{new_resource.system_name}'s include-groups to #{combined}" do
        dc_v36_system_def_update(source, new_resource.system_name, include_groups: combined)
      end
    end
  else
    file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
    raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition' unless ::File.exist?(file)
    rtgroup_resource_init(file)
    config = rtgroup_resource(file).variables[:config]
    sd = config.system_def(name: new_resource.system_name)
    raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition' if sd.nil?
    combined = []
    sd[:include_groups].each do |g|
      combined.push(g)
    end
    new_resource.groups.each do |g|
      combined.push(g) unless combined.include?(g)
    end
    if combined.length > sd[:include_groups].length
      converge_by "Setting systemDef #{new_resource.system_name}'s include-groups to #{combined}" do
        config.system_def_update(name: new_resource.system_name, include_groups: combined)
      end
    end
  end
end

# removes any existing groups from existing systemDef, the group exists and the groups are present
action :remove do
  raise Chef::Exceptions::ValidationFailed, 'groups property is required when using :add action' if new_resource.groups.nil?
  if datacollection_v36?
    source = dc_v36_source_for_file(new_resource.file_name)
    sd = dc_v36_system_def(source, new_resource.system_name)
    unless sd.nil?
      current_groups = sd[:include_groups] || []
      reduced = current_groups.reject { |g| new_resource.groups.include?(g) }
      if reduced.length < current_groups.length
        converge_by "Setting systemDef #{new_resource.system_name}'s include-groups to #{reduced}" do
          dc_v36_system_def_update(source, new_resource.system_name, include_groups: reduced)
        end
      end
    end
  else
    file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
    if ::File.exist?(file)
      rtgroup_resource_init(file)
      config = rtgroup_resource(file).variables[:config]
      sd = config.system_def(name: new_resource.system_name)
      unless sd.nil?
        reduced = []
        sd[:include_groups].each do |g|
          reduced.push(g) unless new_resource.groups.include?(g)
        end
        if reduced.length < sd[:include_groups].length
          converge_by "Setting systemDef #{new_resource.system_name}'s include-groups to #{reduced}" do
            config.system_def_update(name: new_resource.system_name, include_groups: reduced)
          end
        end
      end
    end
  end
end

action :create do
  raise Chef::Exceptions::ValidationFailed, 'Only one of `sysoid, sysoid_mask` is allowed' if !new_resource.sysoid.nil? && !new_resource.sysoid_mask.nil?
  if datacollection_v36?
    source = dc_v36_source_for_file(new_resource.file_name)
    if dc_v36_system_def(source, new_resource.system_name).nil?
      converge_by("Adding systemDef #{new_resource.system_name} to #{source}") do
        dc_v36_system_def_set(source, { name: new_resource.system_name,
                                         sysoid: new_resource.sysoid,
                                         sysoid_mask: new_resource.sysoid_mask,
                                         ip_addrs: new_resource.ip_addrs,
                                         ip_addr_masks: new_resource.ip_addr_masks,
                                         include_groups: new_resource.groups })
      end
    else
      run_action(:update)
    end
  else
    converge_if_changed do
      file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
      rtgroup_resource_init(file, new_resource.file_name[0..new_resource.file_name.rindex('.xml') - 1])
      config = rtgroup_resource(file).variables[:config]
      sd = config.system_def(name: new_resource.system_name)
      if sd.nil?
        config.system_defs.push({ name: new_resource.system_name,
                                  sysoid: new_resource.sysoid,
                                  sysoid_mask: new_resource.sysoid_mask,
                                  ip_addrs: new_resource.ip_addrs,
                                  ip_addr_masks: new_resource.ip_addr_masks,
                                  include_groups: new_resource.groups })
      else
        run_action(:update)
      end
    end
  end
end

action :create_if_missing do
  if datacollection_v36?
    source = dc_v36_source_for_file(new_resource.file_name)
    run_action(:create) if dc_v36_system_def(source, new_resource.system_name).nil?
  else
    file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
    rtgroup_resource_init(file, new_resource.file_name[0..new_resource.file_name.rindex('.xml') - 1])
    config = rtgroup_resource(file).variables[:config]
    sd = config.system_def(name: new_resource.system_name)
    run_action(:create) if sd.nil?
  end
end

action :update do
  raise Chef::Exceptions::ValidationFailed, 'Only one of `sysoid, sysoid_mask` is allowed' if !new_resource.sysoid.nil? && !new_resource.sysoid_mask.nil?
  if datacollection_v36?
    converge_if_changed do
      source = dc_v36_source_for_file(new_resource.file_name)
      current = dc_v36_system_def(source, new_resource.system_name)
      raise Chef::Exceptions::CurrentValueDoesNotExist, "No systemDef found named #{new_resource.system_name} in #{source}" if current.nil?
      # sysoid and sysoid_mask are mutually exclusive: declaring one clears
      # the other, mirroring the file-based update
      sysoid = current[:sysoid]
      sysoid_mask = current[:sysoid_mask]
      unless new_resource.sysoid.nil?
        sysoid = new_resource.sysoid
        sysoid_mask = nil
      end
      unless new_resource.sysoid_mask.nil?
        sysoid_mask = new_resource.sysoid_mask
        sysoid = nil
      end
      dc_v36_system_def_set(source, { name: new_resource.system_name,
                                       sysoid: sysoid,
                                       sysoid_mask: sysoid_mask,
                                       ip_addrs: new_resource.ip_addrs.nil? ? current[:ip_addrs] : new_resource.ip_addrs,
                                       ip_addr_masks: new_resource.ip_addr_masks.nil? ? current[:ip_addr_masks] : new_resource.ip_addr_masks,
                                       include_groups: new_resource.groups.nil? ? current[:include_groups] : new_resource.groups })
    end
  else
    converge_if_changed do
      file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
      rtgroup_resource_init(file)
      config = rtgroup_resource(file).variables[:config]
      sd = config.system_def(name: new_resource.system_name)
      raise Chef::Exceptions::CurrentValueDoesNotExist, "No systemDef found named #{name} in #{file}" if sd.nil?
      config.system_def_update(name: new_resource.system_name,
                               sysoid: new_resource.sysoid,
                               sysoid_mask: new_resource.sysoid_mask,
                               ip_addrs: new_resource.ip_addrs,
                               ip_addr_masks: new_resource.ip_addr_masks,
                               include_groups: new_resource.groups)
    end
  end
end

action :delete do
  if datacollection_v36?
    source = dc_v36_source_for_file(new_resource.file_name)
    unless dc_v36_system_def(source, new_resource.system_name).nil?
      converge_by "Removing system #{new_resource.system_name} from #{source}" do
        dc_v36_system_def_delete(source, new_resource.system_name)
      end
    end
  else
    file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
    if ::File.exist?(file)
      rtgroup_resource_init(file)
      config = rtgroup_resource(file).variables[:config]
      sd = config.system_def(name: new_resource.system_name)
      unless sd.nil?
        converge_by "Removing system #{new_resource.system_name} from #{file}" do
          config.system_def_delete(name: new_resource.system_name)
        end
      end
    end
  end
end
