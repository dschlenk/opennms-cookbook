include Opennms::XmlHelper
include Opennms::Cookbook::Discovery::ConfigurationTemplate
property :ipaddr, String, name_property: true
property :retry_count, Integer
property :timeout, Integer
property :location, String, identity: true
property :foreign_source, String

load_current_value do |new_resource|
  config = disco_resource.variables[:config] unless disco_resource.nil?
  config = Opennms::Cookbook::Discovery::Configuration.read("#{onms_etc}/discovery-configuration.xml") if config.nil?
  specific = config.specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
  current_value_does_not_exist! if specific.nil?
  %i(retry_count timeout foreign_source).each do |p|
    send(p, specific[p])
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Discovery::ConfigurationTemplate
end

action :create do
  converge_if_changed do
    disco_resource_init
    config = disco_resource.variables[:config]
    specific = config.specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
    if specific.nil?
      rp = %i(ipaddr retry_count timeout location foreign_source).map { |p| [p, new_resource.send(p)] }.to_h.compact
      config.add_specific(**rp)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  disco_resource_init
  config = disco_resource.variables[:config]
  specific = config.specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
  run_action(:create) if specific.nil?
end

action :update do
  disco_resource_init
  config = disco_resource.variables[:config]
  specific = config.specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
  raise Chef::Exceptions::ResourceNotFound, "No specific element with IP address #{new_resource.ipaddr} at location #{new_resource.location} found in config file. Use action `:create` or `:create_if_missing` to add it." if specific.nil?
  converge_if_changed do
    %i(retry_count timeout foreign_source).each do |p|
      specific[p] = new_resource.send(p) unless new_resource.send(p).nil?
    end
  end
end

action :delete do
  disco_resource_init
  config = disco_resource.variables[:config]
  specific = config.specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
  converge_by "Removing IP #{new_resource.ipaddr}#{new_resource.location.nil? ? '' : " at location #{new_resource.location}"} from discovery config" do
    config.delete_specific(ipaddr: new_resource.ipaddr, location: new_resource.location)
  end unless specific.nil?
end
