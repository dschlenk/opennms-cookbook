include Opennms::XmlHelper
include Opennms::Cookbook::Syslog::ConfigurationTemplate

property :filename, String, name_property: true
property :position, String, equal_to: %w(bottom top), desired_state: false

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/syslog/#{new_resource.filename}")
  syslog_conf = syslog_resource.variables[:config] unless syslog_resource.nil?
  if syslog_conf.nil?
    ro_syslog_resource_init
    syslog_conf = ro_syslog_resource.variables[:config]
  end
  current_value_does_not_exist! unless syslog_conf.files.include?("syslog/#{new_resource.filename}")
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Syslog::ConfigurationTemplate
end

action :create do
  cookbook_file new_resource.filename do
    path "#{onms_etc}/syslog/#{new_resource.filename}"
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0644'
  end
  converge_if_changed do
    syslog_resource_init
    if new_resource.position.eql?('top')
      syslog_resource.variables[:config].files.unshift("syslog/#{new_resource.filename}")
    else
      syslog_resource.variables[:config].files.push("syslog/#{new_resource.filename}")
    end
  end
end

action :create_if_missing do
  run_action(:create) unless ::File.exist?("#{onms_etc}/syslog/#{new_resource.filename}")
end

action :delete do
  syslog_resource_init
  syslog_resource.variables[:config].files.delete("syslog/#{new_resource.filename}")
  declare_resource(:file, "#{onms_etc}/syslog/#{new_resource.filename}") do
    action :nothing
    delayed_action :delete
    notifies :create, "template[#{onms_etc}/syslogd-configuration.xml]", :immediately
  end
end
