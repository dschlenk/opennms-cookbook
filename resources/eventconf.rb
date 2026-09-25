include Opennms::Cookbook::ConfigHelpers::Event::EventconfSources
unified_mode true

property :event_file, String, name_property: true, identity: true
property :source_type, String, equal_to: %w(cookbook_file template remote_file), default: 'cookbook_file', desired_state: false
property :source, String, desired_state: false
property :source_properties, Hash, desired_state: false
property :variables, Hash, desired_state: false
property :position, String, equal_to: %w(override top bottom), default: 'bottom', desired_state: false

action_class do
  include Opennms::Cookbook::ConfigHelpers::Event::EventconfSources
  include Opennms::Rbac
end

load_current_value do |new_resource|
  resources(service: 'opennms').run_action(:start) unless shell_out('systemctl is-active --quiet opennms').exitstatus == 0
  eventconf_sources_init
  sources = node.run_state['opennms']['eventconf_sources']
  source = sources.select { |s| s['name'] == source_name_from_file(new_resource.event_file) }
  current_value_does_not_exist! if source.nil? || source.empty?
end

action :create do
  eventconf_sources_init
  source_name = source_name_from_file(new_resource.event_file)
  # attr_source = node['opennms']['eventconf_sources']&.select { |s| s['name'] == source_name }&.first
  state_source = node.run_state['opennms']['eventconf_sources']&.select { |s| s['name'] == source_name }&.first
  if state_source.nil?
    converge_by("create eventconf source #{source_name}") do
      update_content(source_name, new_resource.source_type, new_resource.source, new_resource.source_properties, new_resource.variables, new_resource.position)
      # invalidate source cache
      node.run_state['opennms']['eventconf_sources'] = nil
    end
  elsif content_changed?(state_source['id'], source_name, new_resource.source_type, new_resource.source, new_resource.source_properties, new_resource.variables)
    # unfortunately at least as of 36.0.4, lastModified does not reflect changes to events, only the source's properties, so we have to compare content every time
    # if attr_source.nil? || state_source.nil? || attr_source['lastModified'] < state_source['lastModified']
    converge_by("update eventconf source #{source_name}") do
      update_content(source_name, new_resource.source_type, new_resource.source, new_resource.source_properties, new_resource.variables, new_resource.position)
      # invalidate source cache
      node.run_state['opennms']['eventconf_sources'] = nil
    end
  end
end

action :create_if_missing do
  converge_if_changed do # only true if it does not exist
    run_action(:create)
  end
end

action :delete do
  eventconf_sources_init
  sources = node.run_state['opennms']['eventconf_sources']
  source_name = source_name_from_file(new_resource.event_file)
  source = sources.select { |s| s['name'] == source_name }
  if !source.nil? && !source.empty?
    converge_by("delete eventconf source #{source_name}") do
      id = source.first['id']
      delete_source(id)
      # invalidate source cache
      node.run_state['opennms']['eventconf_sources'] = nil
      # remove from attributes
      node.force_override['opennms']['eventconf_sources'].delete_if { |s| s['id'] = id }
    end
  end
end
