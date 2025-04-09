require 'rexml/document'

class TranslationSpec < Inspec.resource(1)
  name 'translation_spec'

  desc '
    OpenNMS translation_spec
  '

  example 'describe translation_spec("uei.opennms.org/anUei", [{assignment: {name: "name", type: "field", value: {type: "constant", result: "uei.opennms.org/translatedUei"}}}]) do
    it { should exist } 
  end'

  def initialize(uei, mappings)
    @exists = false
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/translator-configuration.xml').content)
    doc.root.each_element("/event-translator-configuration/translation/event-translation-spec[@uei = '#{uei}']") do |spec|
      imappings = []
      spec.each_element('mappings/mapping') do |mapping|
        preserve_snmp_data = mapping.attributes['preserve-snmp-data']
        assignments = []
        mapping.each_element('assignment') do |assignment|
          atype = assignment.attributes['type']
          aname = assignment.attributes['name']
          adefault = assignment.attributes['default']
          avalue = parse_value(assignment.elements['value'])
          assignments.push({ name: aname, type: atype, default: adefault, value: avalue }.compact)
        end
        imappings.push({ assignments: assignments, preserve_snmp_data: preserve_snmp_data }.compact)
      end
      if mappings.eql?(imappings)
        @exists = true
        break
      end
    end
  end

  def exist?
    @exists
  end

  def parse_value(v)
    values = []
    v.each_element('value') do |v2|
      values.push parse_value(v2)
    end
    { type: v.attributes['type'], result: v.attributes['result'], matches: v.attributes['matches'], name: v.attributes['name'], values: values }.compact
  end

  def method_missing(param)
    @params[param]
  end
end
