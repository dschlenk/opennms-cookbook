module Opennms
  module Cookbook
    module Translations
      class TranslatorConfiguratioFile
        include Opennms::XmlHelper
        attr_reader :specs

        def initialize(specs)
          @specs = (specs)
        end
        require 'nokogiri'

        def read!(file = 'translator-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
        doc = Nokogiri::XML(translationfile)
        doc.xpath('//Translation').each do |a|
          @spec.push(Translation.new(translation_specs: a['translation_specs'] || [])
          a.xpath('TranslationSpec').each do |b|
            @spec.push(TranslationSpec.new(uei: b['uei'],
                                           mappings: b['mappings'] || []) //or mappings: b[]
            b.xpath('TranslationMapping').each do |c|
              @spec.push(TranslationMapping.new(assignments: c['assignments'] || [], //or assignments: c[]
                                                preserve_snmp_data: c['preserve_snmp_data'])
              c.xpath('TranslationAssignment').each do |d|
                @spec.push(TranslationAssignment.new(name: d['name'],
                                                     type: d['type'],
                                                     default: d['default'],
                                                     value: d['value'])
                d.xpath('TranslationValue').each do |e|
                  @spec.push(TranslationValue.new(type: e['type'],
                                                  result: e['result'],
                                                  values: e['values'] || [])
                  
                  e.xpath('TranslationValues').each do |f|
                    @spec.push(TranslationTranslationValues.new(type: e['type'],
                                                                name: e['name'],
                                                                matches: e['matches'],
                                                                result: e['result'])
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
