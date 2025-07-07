include Opennms::XmlHelper
include Opennms::Cookbook::Jms::JmsNbTemplate

property :destination, String, name_property: true
property :first_occurence_only, [true, false], default: false
property :send_as_object_message, [true, false], default: false
property :destination_type, String, default: 'QUEUE', equal_to: %w(QUEUE TOPIC)
property :message_format, String, required: false

CONFIG_PATH = '/opt/opennms/etc/jms-northbounder-configuration.xml'

load_current_value do |new_resource|
  Chef::Log.debug("Loading current value for destination: #{new_resource.destination}")

  jms_nb_resource_init
  config = jms_nb_resource&.variables[:config]

  raise 'FATAL: JMS NB config is nil after init in load_current_value' if config.nil?

  if new_resource.destination.nil? || new_resource.destination.strip.empty?
    raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.'
  end

  Chef::Log.debug("Looking for destination '#{new_resource.destination}' in config...")
  dest = config.destination(destination: new_resource.destination)

  if dest.nil?
    Chef::Log.debug("Destination '#{new_resource.destination}' not found in config.")
    current_value_does_not_exist!
  else
    Chef::Log.debug("Destination found: #{dest.inspect}")
    first_occurence_only dest.first_occurence_only
    send_as_object_message dest.send_as_object_message
    destination_type dest.destination_type
    message_format dest.message_format
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Jms::JmsNbTemplate

  def ensure_jms_plugin_installed!
    unless node['opennms']['plugin']['addl'].include?('opennms-plugin-northbounder-jms')
      raise 'The opennms-plugin-northbounder-jms plugin must be installed to use the jms_nb_destination resource.'
    end
  end

  def ensure_config_file_exists!
    unless ::File.exist?(CONFIG_PATH)
      Chef::Log.warn("Creating missing JMS config file at #{CONFIG_PATH}")
      ::File.write(CONFIG_PATH, '<jms-northbounder-configuration></jms-northbounder-configuration>')
      FileUtils.chown('opennms', 'opennms', CONFIG_PATH)
    end
  end

  def jms_nb_resource_init
    ensure_config_file_exists!
    unless node.run_state[:jms_nb_resource]
      Chef::Log.debug("Initializing JMS NB config from #{CONFIG_PATH}")
      node.run_state[:jms_nb_resource] = jms_nb_resource_from_file(CONFIG_PATH)
    end
  end

  def jms_nb_resource
    node.run_state[:jms_nb_resource]
  end
end

action :create do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    jms_nb_resource_init
    config = jms_nb_resource.variables[:config]
    raise 'FATAL: JMS NB config is nil during :create' if config.nil?

    dest = config.destination(destination: new_resource.destination)

    if dest.nil?
      Chef::Log.debug("Creating new JMS destination: #{new_resource.destination}")
      config.destinations.push(
        Opennms::Cookbook::Jms::JmsDestination.new(
          destination: new_resource.destination,
          first_occurence_only: new_resource.first_occurence_only,
          send_as_object_message: new_resource.send_as_object_message,
          destination_type: new_resource.destination_type,
          message_format: new_resource.message_format
        )
      )
    else
      Chef::Log.debug("Updating existing JMS destination: #{new_resource.destination}")
      dest.update(
        first_occurence_only: new_resource.first_occurence_only,
        send_as_object_message: new_resource.send_as_object_message,
        destination_type: new_resource.destination_type,
        message_format: new_resource.message_format
      )
    end
  end
end

action :create_if_missing do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  jms_nb_resource_init
  config = jms_nb_resource.variables[:config]
  raise 'FATAL: JMS NB config is nil during :create_if_missing' if config.nil?

  dest = config.destination(destination: new_resource.destination)
  run_action(:create) if dest.nil?
end

action :update do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    jms_nb_resource_init
    config = jms_nb_resource.variables[:config]
    raise 'FATAL: JMS NB config is nil during :update' if config.nil?

    dest = config.destination(destination: new_resource.destination)
    if dest.nil?
      raise Chef::Exceptions::ResourceNotFound, "No JMS destination named '#{new_resource.destination}' found in config. Use :create or :create_if_missing to define it."
    else
      dest.update(
        first_occurence_only: new_resource.first_occurence_only,
        send_as_object_message: new_resource.send_as_object_message,
        destination_type: new_resource.destination_type,
        message_format: new_resource.message_format
      )
    end
  end
end

action :delete do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  jms_nb_resource_init
  config = jms_nb_resource.variables[:config]
  raise 'FATAL: JMS NB config is nil during :delete' if config.nil?

  dest = config.destination(destination: new_resource.destination)
  unless dest.nil?
    converge_by "Removing JMS destination #{new_resource.destination}" do
      config.delete_destination(destination: new_resource.destination)
    end
  end
end
