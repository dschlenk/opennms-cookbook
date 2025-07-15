include Opennms::XmlHelper
include Opennms::Cookbook::JmsNbTemplate

property :destination, String, name_property: true
property :first_occurrence_only, [true, false], default: false
property :send_as_object_message, [true, false]
property :destination_type, String, equal_to: %w(QUEUE TOPIC)
property :message_format, String

load_current_value do |new_resource|
  res = jms_nb_resource
  if res.nil?
    Chef::Log.warn('no existing resource, creating RO')
    ro_jms_nb_resource_init
    res = ro_jms_nb_resource
  else
    Chef::Log.warn('using RW resource')
  end

  if res && res.variables[:config]
    config = res.variables[:config]
  else
    raise 'Unable to load JMS configuration. Is the plugin installed?'
  end

  dest = config.find_destination_by_name(new_resource.destination)
  current_value_does_not_exist! if dest.nil?
  unless dest.first_occurrence_only.nil?
    first_occurrence_only 'true'.eql?(dest.first_occurrence_only)
  end
  unless dest.send_as_object_message.nil?
    send_as_object_message 'true'.eql?(dest.send_as_object_message)
  end
  unless dest.destination_type.nil?
    destination_type dest.destination_type
  end
  unless dest.message_format.nil?
    message_format dest.message_format
  end
end
action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::JmsNbTemplate

  def ensure_jms_plugin_installed!
    unless node['opennms']['plugin']['addl'].include?('opennms-plugin-northbounder-jms')
      raise 'The opennms-plugin-northbounder-jms plugin must be installed to use the jms_nb_destination resource.'
    end
  end

  def jms_config
    jms_nb_resource_init
    res = jms_nb_resource
    res.variables[:config]
  end
end

action :create do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    config = jms_config
    Chef::Log.warn("before creating #{new_resource.name}, config is #{config}")
    dest = config.find_destination_by_name(new_resource.destination)

    if dest.nil?
      Chef::Log.warn('no dest found, adding')
      config.destinations.push(
        Opennms::Cookbook::Jms::JmsDestination.new(
          destination: new_resource.destination,
          first_occurrence_only: new_resource.first_occurrence_only,
          send_as_object_message: new_resource.send_as_object_message,
          destination_type: new_resource.destination_type,
          message_format: new_resource.message_format
        )
      )
    else
      Chef::Log.warn('dest found, updating')
      dest.update(
        first_occurrence_only: new_resource.first_occurrence_only,
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

  config = jms_config
  dest = config.find_destination_by_name(new_resource.destination)
  run_action(:create) if dest.nil?
end

action :update do
  ensure_jms_plugin_installed!
  raise Chef::Exceptions::ValidationFailed, 'The destination property must be set and not empty.' if new_resource.destination.nil? || new_resource.destination.strip.empty?

  converge_if_changed do
    config = jms_config
    dest = config.find_destination_by_name(new_resource.destination)

    if dest.nil?
      raise Chef::Exceptions::ResourceNotFound, "No JMS destination named #{new_resource.destination} found to update. Use action :create or :create_if_missing to create it."
    else
      dest.update(
        first_occurrence_only: new_resource.first_occurrence_only,
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

  config = jms_config
  dest = config.find_destination_by_name(new_resource.destination)
  unless dest.nil?
    converge_by "Removing JMS destination #{new_resource.destination}" do
      config.delete_destination(destination: new_resource.destination)
    end
  end
end
