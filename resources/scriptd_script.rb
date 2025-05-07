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

  unless config.event_script.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
    current_value_does_not_exist!
  end

  script config.get_script_body(name: new_resource.script_name, language: new_resource.language)
  language new_resource.language
end

action :add do
  config = ::Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  return if config.nil?

  if config.event_script.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
    Chef::Log.info("Script '#{new_resource.script_name}' already exists.")
  else
    converge_by("Adding script '#{new_resource.script_name}'") do
      config.add_script(
        name: new_resource.script_name,
        language: new_resource.language,
        script: new_resource.script,
        type: new_resource.type,
        uei: new_resource.uei
      )
      config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' added.")
    end
  end
end

action :delete do
  config = ::Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  return if config.nil?

  if config.event_script.any? { |script| script.language == new_resource.language && script.script.include?(new_resource.script_name) }
    converge_by("Deleting script '#{new_resource.script_name}'") do
      config.delete_script(
        name: new_resource.script_name,
        language: new_resource.language
      )
      config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' deleted.")
    end
  else
    Chef::Log.info("Script '#{new_resource.script_name}' not found.")
  end
end
