include Opennms::XmlHelper
unified_mode true

property :script_name, String, name_property: true
property :language, String, required: true
property :script, String
property :type, String, equal_to: ['start', 'stop', 'reload', 'event'], default: 'event'
property :uei, [String, Array]

action_class do
  include Opennms::XmlHelper
end

load_current_value do |new_resource|
  config = new_resource.script unless new_resource.script.nil?
  if config.nil?
    config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  end
  current_value_does_not_exist! unless config&.script_exists?(language: new_resource.language, script: new_resource.script)
  script new_resource.script
  language new_resource.language
end

action :add do
  config = new_resource.script unless new_resource.script.nil?
  if config.nil?
    config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
    return if config.nil?
  end
  unless config.script_exists?(language: new_resource.language, script: new_resource.script)
    converge_by("Adding script '#{new_resource.script_name}'") do
      config.add_script(
        name: new_resource.script_name,
        language: new_resource.language,
        script: new_resource.script
      )
      Chef::Log.info("Script '#{new_resource.script_name}' added.")
    end
  else
    Chef::Log.info("Script '#{new_resource.script_name}' already exists.")
  end
end

action :delete do
  config = new_resource.script unless new_resource.script.nil?
  if config.nil?
    config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
    return if config.nil?
  end
  if config.script_exists?(language: new_resource.language, script: new_resource.script)
    converge_by("Deleting script '#{new_resource.script_name}'") do
      config.delete_script(language: new_resource.language, script: new_resource.script)
      Chef::Log.info("Script '#{new_resource.script_name}' deleted.")
    end
  else
    Chef::Log.info("Script '#{new_resource.script_name}' not found.")
  end
end
