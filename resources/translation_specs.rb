property :specs, Array, required: true, callback:  {
  'should be a Hash with string keys and values' => lambda { |a|
    !a.any? { |v| !v.is_a?(TranslationSpec) }
  },
}

include Opennms::XmlHelper
include Opennms::Cookbook::Translations::TranslationsTemplate

load_current_value do |new_resource|
  config = translation_resource.variables[:config] unless translation_resource.nil?
  config = Opennms::Cookbook::Translations::TranslatorConfigurationFile.read("#{onms_etc}/translator-configuration.xml") if config.nil?
  raise 'Configuration not found!' if config.nil?
  current_value_does_not_exist! unless config.event_translation_specs?(specs: new_resource.specs)
  specs new_resource.specs
end

action_class do
  include Opennms::Cookbook::Translations::TranslationsTemplate
  include Opennms::XmlHelper
end

action :add do
  converge_if_changed do
    translation_resource_init
    config = translation_resource.variables[:config]
    new_resource.specs.each do |spec|
      config.specs.push(spec) unless config.specs.include?(spec)
    end
  end
end

action :delete do
  config = translation_resource.variables[:config] unless translation_resource.nil?
  config = Opennms::Cookbook::Translations::TranslatorConfigurationFile.read("#{onms_etc}/translator-configuration.xml") if config.nil?
  existing_specs = []
  new_resource.specs.each do |spec|
    existing_specs.push spec if config.specs.include?(spec)
  end
  converge_by "Removing specs #{existing_specs}." do
    config.delete_specs(specs: existing_specs)
  end unless existing_specs.empty?
end
