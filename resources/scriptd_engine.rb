resources/scriptd_engine.rb


include Opennms::Cookbook::Scriptd::ScriptdTemplate

property :language, String, name_property: true
property :class_name, String, required: true
property :extensions, String

action_class do
  include Opennms::Cookbook::Scriptd::ScriptdTemplate
end

load_current_value do |new_resource|
  config = scriptd_resource.variables[:config] unless scriptd_resource.nil?
  if config.nil?
    ro_scriptd_resource_init
    config = ro_scriptd_resource.variables[:config]
  end
  engines = config.engine.select { |e| e.language == new_resource.language }
  current_value_does_not_exist! if engines.empty?
  raise DuplicateEngines unless engines.one?
  engine = engines.first
  class_name engine.class_name
  extensions engine.extensions
end

action :create do
  converge_if_changed do
    scriptd_resource_init
    config = scriptd_resource.variables[:config]
    engines = config.engine.select { |e| e.language == new_resource.language }
    raise DuplicateEngines unless engines.one? || engines.empty?
    if engines.one?
      run_action(:update)
    else
      config.add_engine(
        language: new_resource.language,
        class_name: new_resource.class_name,
        extensions: new_resource.extensions
      )
    end
  end
end

action :create_if_missing do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engines = config.engine.select { |e| e.language == new_resource.language }
  run_action(:create) if engines.empty?
end

action :update do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engines = config.engine.select { |e| e.language == new_resource.language }
  if engines.empty?
    raise Chef::Exceptions::ResourceNotFound,
          "No engine named #{new_resource.language} found to update. Use the `:create` or `:create_if_missing` actions to create a new engine."
  else
    raise DuplicateEngines unless engines.one?
    e = engines.pop
    e.language = new_resource.language
    e.class_name = new_resource.class_name
    e.extensions = new_resource.extensions
  end
end

action :delete do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engines = config.engine.select { |e| e.language == new_resource.language }

  unless engines.empty?
    converge_by "Removing engine #{engines.first.language}." do
      eng = engines.pop
      config.engine.delete_if { |e| e.language.eql?(eng.language) }
    end
  end
end
