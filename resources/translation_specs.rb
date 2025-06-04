property :specs, Array, required: true, callbacks:  {
  'should be an Array of TranslationSpec objects' => lambda { |a|
    !a.any? { |v| !v.is_a?(Opennms::Cookbook::Translations::TranslationSpec) }
  },
}

include Opennms::XmlHelper
include Opennms::Cookbook::Translations::TranslationsTemplate

load_current_value do |new_resource|
  config = translation_resource.variables[:config] unless translation_resource.nil?
  if config.nil?
    ro_translation_resource_init
    config = ro_translation_resource.variables[:config]
  end
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
      config.specs.push(spec) unless config.specs.any? { |s| s.eql?(spec) }
    end
  end
end

action :delete do
  config = translation_resource.variables[:config] unless translation_resource.nil?
  if config.nil?
    ro_translation_resource_init
    config = ro_translation_resource.variables[:config]
  end
  existing_specs = []
  new_resource.specs.each do |spec|
    existing_specs.push spec if config.specs.any? { |s| s.eql?(spec) }
  end
  converge_by "Removing specs #{existing_specs}." do
    translation_resource_init
    config = translation_resource.variables[:config] unless translation_resource.nil?
    config.delete_specs(specs: existing_specs)
  end unless existing_specs.empty?
end
