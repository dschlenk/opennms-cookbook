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
    engine = config.engine.find { |e| e.language == new_resource.language }
    raise "Engine for language '#{new_resource.language}' already exists" unless engine.nil?

    config.add_engine(
      language: new_resource.language,
      className: new_resource.class_name,
      extensions: new_resource.extensions
    )
  end
end

action :create_if_missing do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engine = config.engine.find { |e| e.language == new_resource.language }
  run_action(:create) if engine.nil?
end

action :update do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engine = config.engine.find { |e| e.language == new_resource.language }

  if engine.nil?
    raise Chef::Exceptions::ResourceNotFound,
          "No engine named #{new_resource.language} found to update. Use the `:create` or `:create_if_missing` actions to create a new engine."
  else
    engine.language = new_resource.language
    engine.class_name = new_resource.class_name
    engine.extensions = new_resource.extensions
  end
end

action :delete do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engine = config.engine.find { |e| e.language == new_resource.language }

  unless engine.nil?
    converge_by "Removing engine #{engine.language}." do
      config.delete_engine(engine)
    end
  end
end
