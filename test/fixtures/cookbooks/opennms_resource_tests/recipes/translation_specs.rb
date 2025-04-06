log 'calltranslationspecs'
value = Opennms::Cookbook::Translations::TranslationValue.new(type: 'constant', result: 'uei.opennms.org/translatedUei')
assignment = Opennms::Cookbook::Translations::TranslationAssignment.new(name: 'uei', type: 'field', value: value)
mapping = Opennms::Cookbook::Translations::TranslationMapping.new(assignments: [assignment])
spec = Opennms::Cookbook::Translations::TranslationSpec.new(uei: 'uei.opennms.org/fakeUei')
spec.mappings.push mapping
opennms_translation_specs 'adding spec' do
  specs [spec]
end

log 'calltranslationspecs2'

value1 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'constant',
  result: 'uei.opennms.org/translatedUei'
)
value2 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'constant',
  result: 'Major'
)
value3 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'expression',
  result: 'Issue detected on ${ifName}: ${alarmText}'
)
value4 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'sql',
  result: 'SELECT snmpIfName FROM snmpInterface WHERE nodeid = ?::integer AND snmpifindex = ?::integer',
  values: [
    Opennms::Cookbook::Translations::TranslationValue.new(type: 'field', name: 'nodeid', matches: '.*', result: '${0}'),
    Opennms::Cookbook::Translations::TranslationValue.new(type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}'),
  ]
)

assignment1 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'uei',
  type: 'field',
  value: value1
)
assignment2 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'severity',
  type: 'field',
  value: value2
)
assignment3 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'description',
  type: 'field',
  value: value3
)
assignment4 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'ifName',
  type: 'parameter',
  default: 'Unknown',
  value: value4
)

mapping = Opennms::Cookbook::Translations::TranslationMapping.new(
  assignments: [assignment1, assignment2, assignment3, assignment4]
)

spec = Opennms::Cookbook::Translations::TranslationSpec.new(
  uei: 'uei.opennms.org/fakeUei2'
)
spec.mappings.push(mapping)

opennms_translation_specs 'adding second spec' do
  specs [spec]
end
