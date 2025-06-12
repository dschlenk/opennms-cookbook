value1 = Opennms::Cookbook::Translations::TranslationValue.new(type: 'constant', result: 'uei.opennms.org/translatedUei')
assignment1 = Opennms::Cookbook::Translations::TranslationAssignment.new(name: 'uei', type: 'field', value: value1)
mapping1 = Opennms::Cookbook::Translations::TranslationMapping.new(assignments: [assignment1])
spec1 = Opennms::Cookbook::Translations::TranslationSpec.new(uei: 'uei.opennms.org/fakeUei')
spec1.mappings.push mapping1
opennms_translation_specs 'adding spec1' do
  specs [spec1]
end

value21 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'constant',
  result: 'uei.opennms.org/translatedUei'
)

value22 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'constant',
  result: 'Major'
)

value23 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'expression',
  result: 'Issue detected on ${ifName}: ${alarmText}'
)

value24 = Opennms::Cookbook::Translations::TranslationValue.new(
  type: 'sql',
  result: 'SELECT snmpIfName FROM snmpInterface WHERE nodeid = ?::integer AND snmpifindex = ?::integer',
  values: [
    Opennms::Cookbook::Translations::TranslationValue.new(type: 'field', name: 'nodeid', matches: '.*', result: '${0}'),
    Opennms::Cookbook::Translations::TranslationValue.new(type: 'parameter', name: '~^\\.1\\.3\\.6\\.1\\.2\\.1\\.2\\.2\\.1\\.1\\.([0-9]*)$', matches: '.*', result: '${0}'),
  ]
)

assignment21 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'uei',
  type: 'field',
  value: value21
)

assignment22 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'severity',
  type: 'field',
  value: value22
)

assignment23 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'description',
  type: 'field',
  value: value23
)

assignment24 = Opennms::Cookbook::Translations::TranslationAssignment.new(
  name: 'ifName',
  type: 'parameter',
  default: 'Unknown',
  value: value24
)

mapping2 = Opennms::Cookbook::Translations::TranslationMapping.new(
  assignments: [assignment21, assignment22, assignment23, assignment24]
)

spec2 = Opennms::Cookbook::Translations::TranslationSpec.new(
  uei: 'uei.opennms.org/fakeUei2'
)

spec2.mappings.push(mapping2)

opennms_translation_specs 'adding second spec' do
  specs [spec2]
end

delete_spec = Opennms::Cookbook::Translations::TranslationSpec.new(uei: 'uei.opennms.org/external/hyperic/alert')
delete_value = Opennms::Cookbook::Translations::TranslationValue.new(type: 'constant', result: 'uei.opennms.org/internal/translator/hypericAlert')
delete_assignment1 = Opennms::Cookbook::Translations::TranslationAssignment.new(name: 'uei', type: 'field', value: delete_value)
delete_value2 = Opennms::Cookbook::Translations::TranslationValue.new(type: 'sql', result: 'SELECT n.nodeid FROM node n WHERE n.foreignid = ? AND n.foreignsource = ?')
delete_value3 = Opennms::Cookbook::Translations::TranslationValue.new(type: 'parameter', name: 'platform.id', matches: '.*', result: '${0}')
delete_value4 = Opennms::Cookbook::Translations::TranslationValue.new(type: 'parameter', name: 'alert.source', matches: '.*', result: '${0}')
delete_value2.values.push(delete_value3)
delete_value2.values.push(delete_value4)
delete_assignment2 = Opennms::Cookbook::Translations::TranslationAssignment.new(name: 'nodeid', type: 'field', value: delete_value2)
delete_mapping = Opennms::Cookbook::Translations::TranslationMapping.new(assignments: [delete_assignment1, delete_assignment2])
delete_spec.mappings.push(delete_mapping)

opennms_translation_specs 'delete hypericAlert spec' do
  specs [delete_spec]
  action :delete
end
