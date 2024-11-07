include Opennms::XmlHelper

unified_mode true

property :group_name, String, name_property: true
property :file_name, String, identity: true
# required for :create
property :resource_type, String
# required for :create
property :resource_uri, String
property :dialect, String
property :filter, String
# required for :create
property :attribs, Array, callbacks: {
  'should be an array of hashes with the following required string keys with string values: `name`, `alias`, `type` (matches `([Cc](ounter|OUNTER)|[Gg](auge|AUGE)|[Ss](tring|TRING))`) and the following optional string keys with string values: `index-of`, `filter`' => lambda { |p|
    !p.any? { |h| !h.is_a?(Hash) || !h.key?('name') || !h['name'].is_a?(String) || !h.key?('alias') || !h['alias'].is_a?(String) || !h.key?('type') || !h['type'].is_a?(String) || !h['type'].match(/([Cc](ounter|OUNTER)|[Gg](auge|AUGE)|[Ss](tring|TRING))/) || (h.key?('index-of') && !h['index-of'].is_a?(String)) || (h.key?('filter') && !h['filter'].is_a?(String)) }
  },
}
property :position, String, equal_to: %w(top bottom), deprecated: 'there is no utility in defining group order; therefore this property is now ignored and will be removed in a future release'

include Opennms::Cookbook::Collection::WsmanCollectionTemplate

load_current_value do |new_resource|
  # ignore deprecated property
  position new_resource.position unless new_resource.position.nil?
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  current_value_does_not_exist! unless ::File.exist?(file)
  r = wsman_resource(file)
  all = if r.nil?
          Opennms::Cookbook::Collection::WsmanCollectionConfigFile.read(file, 'wsman').groups
        else
          r.variables[:groups]
        end
  current_value_does_not_exist! if all.empty?
  groups = all.select { |sd| sd.name.eql?(new_resource.group_name) }
  current_value_does_not_exist! if groups.nil? || groups.empty?
  raise Opennms::Cookbook::Collection::DuplicateWsmanGroup, "More than one group with name #{new_resource.group_name} found in #{file}!" unless groups.one?
  group = groups.pop
  resource_type group.resource_type
  resource_uri group.resource_uri
  dialect group.dialect
  filter group.filter
  attribs group.attribs
end

action_class do
  include Opennms::Cookbook::Collection::WsmanCollectionTemplate
end

action :create do
  converge_if_changed do
    file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
    r = wsman_resource(file)
    all = if r.nil?
            Opennms::Cookbook::Collection::WsmanCollectionConfigFile.read(file, 'wsman').groups
          else
            r.variables[:groups]
          end
    groups = all.select { |sd| sd.name.eql?(new_resource.group_name) }
    unless groups.empty?
      raise Opennms::Cookbook::Collection::DuplicateWsmanGroup, "More than one group with name #{new_resource.group_name} found in #{file}!" unless groups.one?
      group = groups.pop
    end
    if group.nil?
      raise Chef::Exceptions::ValidationFailed, 'property resource_type is required when creating a new wsman group' if new_resource.resource_type.nil?
      raise Chef::Exceptions::ValidationFailed, 'property resource_uri is required when creating a new wsman group' if new_resource.resource_uri.nil?
      raise Chef::Exceptions::ValidationFailed, 'property attribs is required when creating a new wsman group' if new_resource.attribs.nil?
      wsman_resource_init(file)
      wsman_resource(file).variables[:groups].push(Opennms::Cookbook::Collection::WsmanGroup.new(name: new_resource.group_name, resource_type: new_resource.resource_type, resource_uri: new_resource.resource_uri, dialect: new_resource.dialect, filter: new_resource.filter, attribs: new_resource.attribs))
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed do
    file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
    wsman_resource_init(file)
    r = wsman_resource(file)
    if r.nil?
      raise Chef::Exceptions::CurrentValueDoesNotExist if group.nil?
    else
      all = r.variables[:groups]
    end
    groups = all.select { |sd| sd.name.eql?(new_resource.group_name) }
    unless groups.empty?
      raise Opennms::Cookbook::Collection::DuplicateWsmanGroup, "More than one group with name #{new_resource.group_name} found in #{file}!" unless groups.one?
      group = groups.pop
    end
    raise Chef::Exceptions::CurrentValueDoesNotExist if group.nil?
    r.variables[:groups].map do |g|
      if g.name.eql?(new_resource.group_name)
        g.update(resource_type: new_resource.resource_type, resource_uri: new_resource.resource_uri, dialect: new_resource.dialect, filter: new_resource.filter, attribs: new_resource.attribs)
      end
    end
  end
end

action :delete do
  file = new_resource.file_name.nil? ? "#{onms_etc}/wsman-datacollection-config.xml" : "#{onms_etc}/#{new_resource.file_name}"
  if ::File.exist?(file)
    wsman_resource_init(file)
    r = wsman_resource(file)
    unless r.nil?
      groups = r.variables[:groups].select { |sd| sd.name.eql?(new_resource.group_name) }
      unless groups.empty?
        raise Opennms::Cookbook::Collection::DuplicateWsmanGroup, "More than one group with name #{new_resource.group_name} found in #{file}!" unless groups.one?
        converge_by "Removing #{new_resource.group_name} from #{file}" do
          r.variables[:groups].delete_if { |g| g.name.eql?(new_resource.group_name) }
        end
      end
    end
  end
end
