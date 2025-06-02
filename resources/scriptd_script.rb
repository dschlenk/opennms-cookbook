include Opennms::XmlHelper
include Opennms::Cookbook::Scriptd::ScriptdTemplate
unified_mode true

property :script_name, String, name_property: true
property :language, String, required: true
property :script, String
property :type, String, equal_to: %w(start stop reload event), default: 'event'
property :uei, [String, Array]

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Scriptd::ScriptdTemplate
end

load_current_value do |new_resource|
  template = scriptd_resource
  if template.nil?
    ro_scriptd_resource_init
    template = ro_scriptd_resource
  end
  config = template.variables[:config]
  case new_resource.type
  when 'start'
    current_value_does_not_exist! unless config.start_script.select { |ss| ss.language.eql?(new_resource.language) && ss.script.eql?(new_resource.script) }.one?
  when 'stop'
    current_value_does_not_exist! unless config.stop_script.select { |s| s.language.eql?(new_resource.language) && s.script.eql?(new_resource.script) }.one?
  when 'reload'
    current_value_does_not_exist! unless config.reload_script.select { |rs| rs.language.eql?(new_resource.language) && rs.script.eql?(new_resource.script) }.one?
  when 'event'
    current_value_does_not_exist! unless config.event_script.select { |es| es.language.eql?(new_resource.language) && es.script.eql?(new_resource.script) && Array(es.uei) == Array(new_resource.uei) }.one?
  end
  # since changing isn't supported, we either didn't find it above and already exited, or we did, and now we make the current value match the new value (since it does)
  type new_resource.type
  language new_resource.language
  script new_resource.script
  uei new_resource.uei
end

action :add do
  converge_if_changed do
    scriptd_resource_init
    template = scriptd_resource
    config = template.variables[:config]
    config.add_script(
      language: new_resource.language,
      script: new_resource.script,
      type: new_resource.type,
      uei: new_resource.uei
    )
  end
end

action :delete do
  template = scriptd_resource
  if template.nil?
    ro_scriptd_resource_init
    template = ro_scriptd_resource
  end
  config = template.variables[:config]
  case new_resource.type
  when 'start'
    if config.start_script.select { |ss| ss.language.eql?(new_resource.language) && ss.script.eql?(new_resource.script) }.one?
      converge_by("Deleting script '#{new_resource.script_name}'") do
        scriptd_resource_init
        template = scriptd_resource
        config = template.variables[:config]
        config.delete_script(
          language: new_resource.language,
          script: new_resource.script,
          type: new_resource.type,
          uei: new_resource.type
        )
      end
    end
  when 'stop'
    if config.stop_script.select { |s| s.language.eql?(new_resource.language) && s.script.eql?(new_resource.script) }.one?
      converge_by("Deleting script '#{new_resource.script_name}'") do
        scriptd_resource_init
        template = scriptd_resource
        config = template.variables[:config]
        config.delete_script(
          language: new_resource.language,
          script: new_resource.script,
          type: new_resource.type,
          uei: new_resource.type
        )
      end
    end
  when 'reload'
    if config.reload_script.select { |rs| rs.language.eql?(new_resource.language) && rs.script.eql?(new_resource.script) }.one?
      converge_by("Deleting script '#{new_resource.script_name}'") do
        scriptd_resource_init
        template = scriptd_resource
        config = template.variables[:config]
        config.delete_script(
          language: new_resource.language,
          script: new_resource.script,
          type: new_resource.type,
          uei: new_resource.type
        )
      end
    end
  when 'event'
    if config.event_script.select { |es| es.language.eql?(new_resource.language) && es.script.eql?(new_resource.script) && es.uei.eql?(new_resource.uei) }.one?
      converge_by("Deleting script '#{new_resource.script_name}'") do
        scriptd_resource_init
        template = scriptd_resource
        config = template.variables[:config]
        config.delete_script(
          language: new_resource.language,
          script: new_resource.script,
          type: new_resource.type,
          uei: new_resource.type
        )
      end
    end
  end
end
