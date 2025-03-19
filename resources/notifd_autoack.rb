property :uei, String, name_property: true
property :acknowledge, String, required: true, identity: true
# default to 'RESOLVED: ' on new
property :resolution_prefix, String
property :notify, [true, false]
# Array of strings. At least one required. Defaults to a single string - 'nodeid' on new
property :matches, Array, callbacks: {
  'should be an Array of Strings that is not empty' => lambda { |p|
    !p.empty? && !p.any? { |a| !a.is_a?(String) }
  },
}

include Opennms::XmlHelper
include Opennms::Cookbook::Notification::NotifdTemplate
load_current_value do |new_resource|
  config = notifd_resource.variables[:config] unless notifd_resource.nil?
  if config.nil?
    ro_notifd_resource_init
    config = ro_notifd_resource.variables[:config]
  end
  autoack = config.autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
  current_value_does_not_exist! if autoack.nil?
  %i(resolution_prefix notify matches).each do |p|
    send(p, autoack.send(p))
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Notification::NotifdTemplate
end

action :create do
  converge_if_changed do
    notifd_resource_init
    config = notifd_resource.variables[:config]
    autoack = config.autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
    rp = %i(resolution_prefix notify matches).map { |p| [p, new_resource.send(p)] }.to_h.compact
    if autoack.nil?
      rp[:uei] = new_resource.uei
      rp[:acknowledge] = new_resource.acknowledge
      rp[:resolution_prefix] = 'RESOLVED: ' if new_resource.resolution_prefix.nil?
      rp[:matches] = ['nodeid'] if new_resource.matches.nil? || new_resource.matches.empty?
      Chef::Log.warn("rp before creating a new one: #{rp}")
      config.autoacks.push(Opennms::Cookbook::Notification::AutoAck.new(**rp))
    else
      autoack.update(**rp)
    end
  end
end

action :create_if_missing do
  notifd_resource_init
  config = notifd_resource.variables[:config]
  autoack = config.autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
  run_action(:create) if autoack.nil?
end

action :update do
  notifd_resource_init
  config = notifd_resource.variables[:config]
  autoack = config.autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
  raise Chef::Exceptions::ResourceNotFound, "No auto-acknowledge config found with uei #{new_resource.uei} and acknowledge #{new_resource.acknowledge} to update. Use action `:create` or `:create_if_missing` to create one." if autoack.nil?
  run_action(:create)
end

action :delete do
  notifd_resource_init
  config = notifd_resource.variables[:config]
  autoack = config.autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
  converge_by "Removing auto-acknowledge config for UEI #{new_resource.uei} and acknowledge #{new_resource.acknowledge}" do
    config.delete_autoack(uei: new_resource.uei, acknowledge: new_resource.acknowledge)
  end unless autoack.nil?
end
