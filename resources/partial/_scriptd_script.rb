include Opennms::XmlHelper
unified_mode true

property :script_name, String, name_property: true
property :language, String, required: true
property :script, String

action_class do
  include Opennms::XmlHelper
  # include Opennms::Cookbook::
end

load_current_value do |new_resource|
  config = scripty_resource.variables[:config] unless scripty_resource.nil?
  config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml") if config.nil?
  raise 'Configuration not found!' if config.nil?
  current_value_does_not_exist! unless config.script_exists?(language: new_resource.language, script: new_resource.script)
  script new_resource.script
  language new_resource.language
end

action :add do
  config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  raise 'Configuration not found!' if config.nil?
  unless config.script_exists?(language: new_resource.language, script: new_resource.script)
    converge_by("Adding script '#{new_resource.script_name}'") do
      config.add_script(
        name: new_resource.script_name,
        language: new_resource.language,
        script: new_resource.script
      )
      config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' added.")
    end
  else
    Chef::Log.info("Script already exists. Skipping add.")
  end
end

action :delete do
  config = Opennms::Cookbook::Scripty::ScriptyConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
  raise 'Configuration not found!' if config.nil?

  if config.script_exists?(language: new_resource.language, script: new_resource.script)
    converge_by("Deleting script '#{new_resource.script_name}'") do
      config.delete_script(language: new_resource.language, script: new_resource.script)
      config.write("#{onms_etc}/scriptd-configuration.xml")
      Chef::Log.info("Script '#{new_resource.script_name}' deleted.")
    end
  else
    Chef::Log.info("Script not found. Skipping delete.")
  end
end
