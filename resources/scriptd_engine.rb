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
end

action :create_if_missing do
end

action :update do
end

action :delete do
end
