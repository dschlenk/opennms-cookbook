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
  engines = config.engine.select { |e| e[:language].eql?(new_resource.language) }
  current_value_does_not_exist! if engines.empty?
  raise DuplicateEngines unless engines.one?
  engine = engines.pop
  class_name engine[:class_name]
  extensions engine[:extensions]
end

action :create do
  converge_if_changed do
    scriptd_resource_init
    config = scriptd_resource.variables[:config]
    engines = config.engine.find { |e| e.language == new_resource.language }
    raise "Engine for language '#{new_resource.language}' already exists" unless engines.nil? || engines.empty?

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
  engines = config.engine.find { |e| e.language == new_resource.language }
  run_action(:create) if engines.nil? || engines.empty?
end

action :update do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engines = config.engine.find { |e| e.language == new_resource.language }

  if engines.nil? || engines.empty?
    raise Chef::Exceptions::ResourceNotFound,
          "No engine named #{new_resource.language} found to update. Use the `:create` or `:create_if_missing` actions to create a new engine."
  else
    # If engines is an array of one engine, update that engine directly.
    engines.first.update(
      language: new_resource.language,
      className: new_resource.class_name,
      extensions: new_resource.extensions
    )
  end
end

action :delete do
  scriptd_resource_init
  config = scriptd_resource.variables[:config]
  engines = config.engine.find { |e| e.language == new_resource.language }

  unless engines.nil? || engines.empty?
    converge_by "Removing engine #{engines}." do
      config.delete_engine(engines)
    end
  end
end
