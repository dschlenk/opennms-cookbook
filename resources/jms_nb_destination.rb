include Opennms::XmlHelper
include Opennms::Cookbook::Jms::JmsNbTemplate

property :destination, String, name_property: true
property :first_occurence_only, [true, false], default: false
property :send_as_object_message, [true, false], default: false
property :destination_type, String, default: 'QUEUE', equal_to: %w(QUEUE TOPIC)
property :message_format, String, required: false

attr_reader :jms_nb_resource, :ro_jms_nb_resource

load_current_value do |new_resource|
  jms_nb_resource_init
  config = jms_nb_resource&.variables

  if config.nil?
    ro_jms_nb_resource_init
    config = ro_jms_nb_resource&.variables
  end

  if config.nil?
    raise 'Unable to load JMS configuration. Ensure jms_nb_resource or ro_jms_nb_resource is initialized correctly.'
  end

  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  dest = config.find_destination_by_name(new_resource.destination)
  current_value_does_not_exist! if dest.nil?

  first_occurence_only dest.first_occurence_only
  send_as_object_message dest.send_as_object_message
  destination_type dest.destination_type
  message_format dest.message_format
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Jms::JmsNbTemplate

  def ensure_jms_plugin_installed!
    unless node['opennms']['plugin']['addl'].include?('opennms-plugin-northbounder-jms')
      raise 'The opennms-plugin-northbounder-jms plugin must be installed to use the jms_nb_destination resource.'
    end
  end

  def jms_nb_resource_init
    @jms_nb_resource ||= begin
      find_resource(:template, '/opt/opennms/etc/jms-northbounder-configuration.xml')
    rescue StandardError
      nil
    end
  end

  def ro_jms_nb_resource_init
    @ro_jms_nb_resource ||= begin
      find_resource(:template, 'RO /opt/opennms/etc/jms-northbounder-configuration.xml')
    rescue StandardError
      nil
    end
  end
end

action :create do
  ensure_jms_plugin_installed!

  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    jms_nb_resource_init
    config = jms_nb_resource&.variables

    raise 'Unable to load JMS configuration. Ensure jms_nb_resource is initialized correctly.' if config.nil?

    dest = config.find_destination_by_name(new_resource.destination)
    if dest.nil?
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
  config = jms_nb_resource&.variables

  raise 'Unable to load JMS configuration. Ensure jms_nb_resource is initialized correctly.' if config.nil?

  dest = config.find_destination_by_name(new_resource.destination)
  run_action(:create) if dest.nil?
end

action :update do
  ensure_jms_plugin_installed!

  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    jms_nb_resource_init
    config = jms_nb_resource&.variables

    raise 'Unable to load JMS configuration. Ensure jms_nb_resource is initialized correctly.' if config.nil?

    dest = config.find_destination_by_name(new_resource.destination)
    if dest.nil?
      raise Chef::Exceptions::ResourceNotFound, "No JMS destination named #{new_resource.destination} found to update. Use action :create or :create_if_missing to create it."
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
  config = jms_nb_resource&.variables

  raise 'Unable to load JMS configuration. Ensure jms_nb_resource is initialized correctly.' if config.nil?

  dest = config.find_destination_by_name(new_resource.destination)
  unless dest.nil?
    converge_by "Removing JMS destination #{new_resource.destination}" do
      config.delete_destination(destination: new_resource.destination)
    end
  end
end
