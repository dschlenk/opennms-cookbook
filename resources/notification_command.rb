include Opennms::XmlHelper
include Opennms::Cookbook::Notification::CommandsTemplate
property :command_name, String, name_property: true
# required for new
property :execute, String
property :comment, String
property :contact_type, String
# default to true on new
property :binary, [true, false]
# To maintain order, an array of hashes with up to three key/values pairs. Only 'streamed' is required.
# [{'streamed' => '(true|false)', 'substitution' => 'string', 'switch' => 'string'}, {...}]
property :arguments, Array, callbacks: {
  'should be an array of hashes. Each hash must have key `streamed` (true|false) and can have keys `substitution` (string) and `switch` (string)' => lambda { |p|
    !p.any? { |h| !h.key?('streamed') || ![true, false].include?(h['streamed']) || (h.key?('substitution') && !h['substitution'].is_a?(String)) || (h.key?('switch') && !h['switch'].is_a?(String)) }
  },
}
property :service_registry, [true, false]

load_current_value do |new_resource|
  config = nc_resource.variables[:config] unless nc_resource.nil?
  config = Opennms::Cookbook::Notification::CommandsConfigFile.read("#{onms_etc}/notificationCommands.xml") if config.nil?
  command = config.command(command_name: new_resource.command_name)
  current_value_does_not_exist! if command.nil?
  %i(execute comment contact_type binary arguments service_registry).each do |p|
    send(p, command.send(p))
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Notification::CommandsTemplate
end

action :create do
  converge_if_changed do
    nc_resource_init
    config = nc_resource.variables[:config]
    command = config.command(command_name: new_resource.command_name)
    if command.nil?
      raise Chef::Exceptions::ValidationFailed, 'Property `execute` is required for new notification commands' if new_resource.execute.nil?
      rp = %i(command_name execute comment contact_type binary arguments service_registry).map { |p| [p, new_resource.send(p)] }.to_h.compact
      rp[:binary] = true if new_resource.binary.nil?
      config.commands.push(Opennms::Cookbook::Notification::Command.new(**rp))
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  nc_resource_init
  config = nc_resource.variables[:config]
  command = config.command(command_name: new_resource.command_name)
  run_action(:create) if command.nil?
end

action :update do
  nc_resource_init
  config = nc_resource.variables[:config]
  command = config.command(command_name: new_resource.command_name)
  raise Chef::Exceptions::ResourceNotFound, "No command named #{new_resource.command_name} found. Use action `:create` or `:create_if_missing to create a notificaiton command." if command.nil?
  converge_if_changed do
    rp = %i(execute comment contact_type binary arguments service_registry).map { |p| [p, new_resource.send(p)] }.to_h.compact
    command.update(**rp)
  end
end

action :delete do
  nc_resource_init
  config = nc_resource.variables[:config]
  command = config.command(command_name: new_resource.command_name)
  converge_by "Removing notification command #{new_resource.command_name}" do
    config.delete_command(command_name: new_resource.command_name)
  end unless command.nil?
end
