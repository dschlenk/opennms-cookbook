include Opennms::XmlHelper
include Opennms::Cookbook::Collection::ResourceTypeTemplate
include Opennms::Cookbook::Collection::GroupResourceTypeTemplate

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
end

load_current_value do |new_resource|
  file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
  current_value_does_not_exist! unless ::File.exist?(file)
  r = rtgroup_resource(file)
  sd = if r.nil?
         Opennms::Cookbook::Collection::CollectionGroupConfigFile.read(file).system_def(name: new_resource.system_name)
       else
         rtgroup_resource(file).variables[:config].system_def(name: new_resource.system_name)
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

# removes any existing groups from existing systemDef, the group exists and the groups are present
action :remove do
  raise Chef::Exceptions::ValidationFailed, 'groups property is required when using :add action' if new_resource.groups.nil?
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

action :create do
  raise Chef::Exceptions::ValidationFailed, 'Only one of `sysoid, sysoid_mask` is allowed' if !new_resource.sysoid.nil? && !new_resource.sysoid_mask.nil?
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

action :create_if_missing do
  file = "#{onms_etc}/datacollection/#{new_resource.file_name}"
  rtgroup_resource_init(file, new_resource.file_name[0..new_resource.file_name.rindex('.xml') - 1])
  config = rtgroup_resource(file).variables[:config]
  sd = config.system_def(name: new_resource.system_name)
  run_action(:create) if sd.nil?
end

action :update do
  raise Chef::Exceptions::ValidationFailed, 'Only one of `sysoid, sysoid_mask` is allowed' if !new_resource.sysoid.nil? && !new_resource.sysoid_mask.nil?
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

action :delete do
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
