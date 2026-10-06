include Opennms::Cookbook::ConfigHelpers::Event::EventconfSourceRubyBlock
unified_mode true

property :event_file, String, name_property: true, identity: true
property :source_type, String, equal_to: %w(cookbook_file template remote_file), default: 'cookbook_file', desired_state: false
property :source, String, desired_state: false
property :source_properties, Hash, desired_state: false
property :variables, Hash, desired_state: false
property :position, String, equal_to: %w(override top bottom), default: 'bottom', desired_state: false

action_class do
  include Opennms::Cookbook::ConfigHelpers::Event::EventconfSourceRubyBlock
end

load_current_value do |new_resource|
  resources(service: 'opennms').run_action(:start) unless shell_out('systemctl is-active --quiet opennms').exitstatus == 0
  source_name = source_name_from_file(new_resource.event_file)
  current_value_does_not_exist! unless eventconf_source_exist?(source_name)
end

action :create do
  source_name = source_name_from_file(new_resource.event_file)
  eventconf_source_resource_init(source_name, new_resource.position)
  desired_definition = new_definition(source_name, new_resource.source_type, new_resource.source, new_resource.source_properties, new_resource.variables)
  if content_changed?(source_name, desired_definition)
    converge_by("create/update eventconf source #{source_name}") do
      node.run_state['opennms']['eventconf_sources'][source_name]['definition'] = desired_definition
      mark_changed(source_name)
    end
  end
end

action :create_if_missing do
  converge_if_changed do
    run_action(:create)
  end
end

action :delete do
  source_name = source_name_from_file(new_resource.event_file)
  if eventconf_source_exist?(source_name)
    converge_by("delete eventconf source #{source_name}") do
      delete_source(source_name)
    end
  end
end
