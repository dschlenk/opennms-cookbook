include Opennms::XmlHelper
include Opennms::Cookbook::Syslog::ConfigurationTemplate

property :filename, String, name_property: true
# 'bottom' places it near the bottom before these files:
# ncs-component.events.xml
# asset-management.events.xml
# Standard.events.xml
# default.events.xml
#
# 'top' places it just after
# Translator.events.xml
#
# TODO: 'alphabetical' places it in alphabetical order with the other vendor MIBs.
# required for :create
property :position, String, equal_to: %w(bottom top), desired_state: false

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/syslog/#{new_resource.filename}")
  syslog_conf = syslog_resource.variables[:conf] unless syslog_resource.nil?
  syslog_conf = Opennms::Cookbook::Syslog::Configuration.read("#{onms_etc}/syslogd-configuration.xml", node) if syslog_conf.nil?
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

action :delete do
  syslog_resource_init
  syslog_resource.variables[:config].files.delete("syslog/#{new_resource.filename}")
  declare_resource(:file, "#{onms_etc}/syslog/#{new_resource.filename}") do
    action :nothing
    delayed_action :delete
    notifies :create, "template[#{onms_etc}/syslogd-configuration.xml]", :immediately
  end
end
