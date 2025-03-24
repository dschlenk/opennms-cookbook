log 'calltranslationspecs'
assignment = Opennms::Cookbook::Translations::TranslationAssignment.new(name: 'uei', type: 'field', value: Opennms::Cookbook::Translations::TranslationValue.new(type: 'constant', result: 'uei.opennms.org/translatedUei'))
mapping = Opennms::Cookbook::Translations::TranslationMapping.new(assignments: [assignment])
spec = Opennms::Cookbook::Translations::TranslationSpec.new(uei: 'uei.opennms.org/fakeUei')
spec.mappings.push mapping
opennms_translation_specs 'adding spec' do
  specs [spec]
end
