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
  template = scriptd_resource
  if template.nil?
    ro_scriptd_resource_init
    template = ro_scriptd_resource
  end
  config = template.variables[:config]
  case new_resource.type
    when 'start'
      current_value_does_not_exist? if config.start_script.select { |ss| ss.language.eql?(new_resource.language) && ss.script.eql?(new_resource.script) }.one?
    when 'stop'
      # TODO: implement similar to 'start'
    when 'reload'
      # TODO: implement similar to 'start'
    when 'event'
      # TODO: implement similar to 'start' but also taking into account the `uei` field, which can be an array or a string (easiest to coerce it to a single avlue array if it is a string)
  end
  # since changing isn't supported, we either didn't find it above and already exited, or we did, and now we make the current value match the new value (since it does)
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
          config.delete_script( # TODO: implement this method in the library file
            language: new_resource.language,
            script: new_resource.script,
            type: new_resource.type,
            uei: new_resource.type
          )
        end
      end
    when 'stop'
      # TODO: implement similar to 'start'
    when 'reload'
      # TODO: implement similar to 'start'
    when 'event'
      # TODO: implement similar to 'start' but also taking into account the `uei` field, which can be an array or a string (easiest to coerce it to a single avlue array if it is a string)
  end
end
