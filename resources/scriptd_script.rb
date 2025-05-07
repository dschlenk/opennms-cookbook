include Opennms::XmlHelper
unified_mode true

property :script_name, String, name_property: true
property :language, String, required: true
property :script, String
property :type, String, equal_to: %w(start stop reload event), default: 'event'
property :uei, [String, Array]

action_class do
  include Opennms::XmlHelper
end

load_current_value do |new_resource|
  config = ::Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")

  unless [config.config.start_script, config.config.stop_script, config.config.reload_script, config.config.event_script].any? do |script_list|
    script_list.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
  end
    current_value_does_not_exist!
  end

  script config.config.event_script.find { |script| script.language == new_resource.language }&.script
  language new_resource.language
end

action :add do
  config = ::Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  return if config.nil?

  if [config.config.start_script, config.config.stop_script, config.config.reload_script, config.config.event_script].any? do |script_list|
    script_list.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
  end
    Chef::Log.info("Script '#{new_resource.script_name}' already exists.")
  else
    converge_by("Adding script '#{new_resource.script_name}'") do
      config.config.add_script(
        language: new_resource.language,
        script: new_resource.script,
        type: new_resource.type,
        uei: new_resource.uei
      )
      config.config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' added.")
    end
  end
end

action :delete do
  config = ::Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  return if config.nil?

  if [config.config.start_script, config.config.stop_script, config.config.reload_script, config.config.event_script].any? do |script_list|
    script_list.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
  end
    converge_by("Deleting script '#{new_resource.script_name}'") do
      config.config.delete_script(
        name: new_resource.script_name,
        language: new_resource.language
      )
      config.config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' deleted.")
    end
  else
    Chef::Log.info("Script '#{new_resource.script_name}' not found.")
  end
end
