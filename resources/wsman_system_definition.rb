include Opennms::XmlHelper

unified_mode true

property :system_name, String, name_property: true
property :groups, Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}
# required for :create
property :rule, String
# main file implied when nil
property :file_name, String, identity: true
property :position, String, equal_to: %w(top bottom), deprecated: 'order is not important therefore this property is now ignored and will be removed in a future release', desired_state: false

include Opennms::Cookbook::Collection::WsmanCollectionTemplate
load_current_value do |new_resource|
  # ignore deprecated property
  position new_resource.position unless position.nil?
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  current_value_does_not_exist! unless ::File.exist?(file)
  r = wsman_resource(file)
  if r.nil?
    Chef::Log.warn("no resource yet, reading from #{file}")
    all = Opennms::Cookbook::Collection::WsmanCollectionConfigFile.read(file, 'wsman').system_definitions
  else
    all = r.variables[:system_definitions]
  end
  Chef::Log.warn("all is #{all}")
  current_value_does_not_exist! if all.empty?
  definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
  Chef::Log.warn("definitions is #{definitions}")
  current_value_does_not_exist! if definitions.nil? || definitions.empty?
  raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" unless definitions.one?
  definition = definitions.pop
  rule definition.rule
  groups definition.include_groups
end

action_class do
  include Opennms::Cookbook::Collection::WsmanCollectionTemplate
end

# adds items in `groups` to list of `include-group` in definition with name `system_name` in `file` if they are not already there
action :add do
  raise Chef::Exceptions::ValidationFailed, 'groups property is required when using :add action' if new_resource.groups.nil?
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing files. Use the :create action to create a new file.' unless ::File.exist?(file)
  wsman_resource_init(file)
  r = wsman_resource(file)
  all = r.variables[:system_definitions]
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition.' if all.empty?
  definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition.' if definitions.empty?
  raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" unless definitions.one?
  definition = definitions.pop
  missing_groups = []
  new_resource.groups.each do |g|
    missing_groups.push(g) unless definition.include_groups.include?(g)
  end unless new_resource.groups.nil?
  unless missing_groups.empty?
    converge_by "Adding #{missing_groups} to system definition #{new_resource.system_name}" do
      r.variables[:system_definitions].map do |sd|
        next unless sd.name.eql?(new_resource.name)
        missing_groups.each do |mg|
          sd.include_groups.push(mg)
        end
      end
    end
  end
end

# removes items in `groups` from list of `include-group` in definition with name `system_name` in `file` if they are there
action :remove do
  raise Chef::Exceptions::ValidationFailed, 'groups property is required when using :add action' if new_resource.groups.nil?
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing files. Use the :create action to create a new file.' unless ::File.exist?(file)
  wsman_resource_init(file)
  r = wsman_resource(file)
  all = r.variables[:system_definitions]
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition.' if all.empty?
  definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
  raise Chef::Exceptions::CurrentValueDoesNotExist, 'The :add action only operates on existing system definitions. Use the :create action to create a new system definition.' if definitions.empty?
  raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" unless definitions.one?
  definition = definitions.pop
  existing_groups = []
  definition.include_groups.each do |g|
    existing_groups.push(g) if new_resource.groups.include?(g)
  end
  unless existing_groups.empty?
    converge_by "Removing #{existing_groups} from #{new_resource.system_name}" do
      r.variables[:system_definitions].map do |sd|
        next unless sd.name.eql?(new_resource.name)
        existing_groups.each do |eg|
          sd.include_groups.delete_if { |s| s.eql?(eg) }
        end
      end
    end
  end
end

# makes definition named `system_name` in `file` match this resource, creating it if necessary
action :create do
  converge_if_changed do
    file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
    wsman_resource_init(file)
    r = wsman_resource(file)
    all = if r.nil?
            Opennms::Cookbook::Collection::WsmanCollectionConfigFile.read(file, 'wsman').system_definitions
          else
            r.variables[:system_definitions]
          end
    definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
    unless definitions.empty?
      raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" unless definitions.one?
      definition = definitions.pop
    end
    if definition.nil?
      wsman_resource_init(file)
      raise Chef::Exceptions::ValidationFailed, 'rule property is required when creating a new system definition' if new_resource.rule.nil?
      wsman_resource(file).variables[:system_definitions].push(Opennms::Cookbook::Collection::WsmanSystemDefinition.new(name: new_resource.name, rule: new_resource.rule, include_groups: new_resource.groups))
    else
      run_action(:update)
    end
  end
end

# makes definition named `system_name` in `file` match this resource
action :update do
  converge_if_changed do
    file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
    raise Chef::Exceptions::CurrentValueDoesNotExist unless ::File.exist?(file)
    wsman_resource_init(file)
    r = wsman_resource(file)
    all = r.variables[:system_definitions]
    definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
    raise Chef::Exceptions::CurrentValueDoesNotExist if definitions.empty?
    raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" unless definitions.one?
    r.variables[:system_definitions].map do |sd|
      if sd.name.eql?(new_resource.system_name)
        sd.update(rule: new_resource.rule, include_groups: new_resource.groups)
      end
    end
  end
end

# removes definition named `system_name` in `file` if it exists
action :delete do
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  raise Chef::Exceptions::CurrentValueDoesNotExist unless ::File.exist?(file)
  wsman_resource_init(file)
  r = wsman_resource(file)
  all = r.variables[:system_definitions]
  definitions = all.select { |sd| sd.name.eql?(new_resource.system_name) }
  raise Opennms::Cookbook::Collection::DuplicateSystemDefinition, "More than one system definition with name #{new_resource.system_name} found in #{file}!" if definitions.length > 1
  unless definitions.empty?
    converge_by "Removing system definition #{new_resource.system_name}" do
      r.variables[:system_definitions].delete_if { |sd| sd.name.eql?(new_resource.system_name) }
    end
  end
end
