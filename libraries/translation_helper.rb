module Opennms
  module Cookbook
    module Translations
      class TranslatorConfiguratioFile
        include Opennms::XmlHelper
        attr_reader :specs

        def initialize(specs)
          @specs = (specs)
        end

        def read!(file = 'translator-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
        doc.xpath('//TranslationValues').each do |a|
          @spec.push(TranslationTranslationValues.new(type: a['type'],
                                                      name: a['name'],
                                                      matches: a['matches'],
                                                      result: a['result'])
          a.xpath('TranslationValue').each do |b|
            @spec.push(TranslationValue.new(type: b['type'],
                                            result: b['result'],
                                            values: b['values'] || [])
            b.xpath('TranslationAssignment').each do |c|
              @spec.push(TranslationAssignment.new(name: c['name'],
                                                   type: c['type'],
                                                   default: c['default'],
                                                   value: c['value'])
              c.xpath('TranslationMapping').each do |d|
                @spec.push(TranslationMapping.new(assignments: d['assignments'] || [], //or assignments: d[]
                                                  preserve_snmp_data: d['preserve_snmp_data'])
                d.xpath('TranslationSpec').each do |e|
                  @spec.push(TranslationSpec.new(uei: e['uei'],
                                                  mappings: e['mappings'] || []) //or mappings: e[]
                  e.xpath(Translation'').each do |f|
                    @spec.push(Translation.new(translation_specs: f['translation_specs'] || []
                  end
                end
              end
            end
          end
        end

        def self.read(file = 'translator-configuration.xml')
          translationfile = TranslatorConfiguratioFile.new
          translationfile.read!(file)
          translationfile
        end
      end

      class Translation
        attr_reader :translation_specs

        def initialize
          @translation_specs = []
        end
      end

      class TranslationSpec
        attr_reader :uei, :mappings

        def initialize(uei:)
          @uei = uei
          @mappings = []
        end
      end

      class TranslationMapping
        attr_reader :assignments, :preserve_snmp_data

        def initialize(assignments: nil, preserve_snmp_data: nil)
          if assignments.nil?
            @assignments = []
          else
            @assignments = assignments
          end
          @preserve_snmp_data = preserve_snmp_data
        end
      end

      class TranslationAssignment
        attr_reader :name, :type, :default, :value

        def initialize(name:, type:,default: nil, value:)
          @name = name
          @type = type
          @default = default
          @value = value
        end
      end

      class TranslationValue
        attr_reader :type, :result, :values

        def initialize(type:, result:, values: nil)
          @type = type
          @result = result
          @values = values || []
        end
      end

      class TranslationValues
        attr_reader :type, :name, :matches, :result

        def initialize(type:, name: nil, matches: nil, result:)
          @type = type
          @name = name
          @matches = matches
          @result = result
          end
      end
    end
  end
end
