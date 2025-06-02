property :notification_name, String, name_property: true
# required for new
property :status, String, equal_to: %w(on off)
property :writeable, String, equal_to: %w(yes no)
# required for new
property :uei, String
property :description, String
# required for new; defaults to `IPADDR != '0.0.0.0'` when new
property :rule, String
property :strict_rule, [true, false]
# jeff says this shouldn't be used
# property :notice_queue, :kind_of => String
# required for new
property :destination_path, String
# required for new
property :text_message, String
property :subject, String
property :numeric_message, String
property :event_severity, String
# string key/value pairs
property :parameters, Hash, callbacks: {
  'should be a Hash with string keys and values' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}
property :vbname, String
property :vbvalue, String

include Opennms::XmlHelper
include Opennms::Cookbook::Notification::NotificationsTemplate
load_current_value do |new_resource|
  config = notifs_resource.variables[:config] unless notifs_resource.nil?
  if config.nil?
    ro_notifs_resource_init
    config = ro_notifs_resource.variables[:config]
  end
  notif = config.notification(name: new_resource.notification_name)
  current_value_does_not_exist! if notif.nil?
  %i(status writeable uei description rule strict_rule text_message subject numeric_message event_severity parameters vbname vbvalue).each do |p|
    send(p, notif.send(p))
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Notification::NotificationsTemplate
end

action :create do
  converge_if_changed do
    notifs_resource_init
    config = notifs_resource.variables[:config]
    notif = config.notification(name: new_resource.notification_name)
    rp = %i(status writeable uei description rule strict_rule destination_path text_message subject numeric_message event_severity parameters vbname vbvalue).map { |p| [p, new_resource.send(p)] }.to_h.compact
    if notif.nil?
      %i(uei destination_path text_message).each do |p|
        raise Chef::Exceptions::ValidationFailed, "Property `#{p}` is required for new notifications." if new_resource.send(p).nil?
      end
      rp[:name] = new_resource.notification_name
      rp[:rule] = "IPADDR != '0.0.0.0'" if new_resource.rule.nil?
      config.notifs.push(Opennms::Cookbook::Notification::Notification.new(**rp))
    else
      notif.update(**rp)
    end
  end
end

action :create_if_missing do
  notifs_resource_init
  config = notifs_resource.variables[:config]
  notif = config.notification(name: new_resource.notification_name)
  run_action(:create) if notif.nil?
end

action :update do
  notifs_resource_init
  config = notifs_resource.variables[:config]
  notif = config.notification(name: new_resource.notification_name)
  raise Chef::Exceptions::ResourceNotFound, "No notification named #{new_resource.notification_name} found to update. Use the `:create` or `:create_if_missing` actions to create a new notification." if notif.nil?
  run_action(:create)
end

action :delete do
  notifs_resource_init
  config = notifs_resource.variables[:config]
  notif = config.notification(name: new_resource.notification_name)
  converge_by "Removing notification #{new_resource.notification_name}." do
    config.delete_notification(name: new_resource.notification_name)
  end unless notif.nil?
end
