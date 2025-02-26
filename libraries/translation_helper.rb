module Opennms
  module Cookbook
    module Translations
      class TranslationFile
        include Opennms::XmlHelper
        attr_reader :addl_specs

        def initialize(addl_specs)
          @addl_specs = (addl_specs)
        end

        def read!(file = 'translator-configuration.xml')
          @addl_specs.each do |uei, data|
          check_mappings(uei, data)
        end

        def check_mappings(uei, data)
          if data[:mappings].nil?
            puts "Mappings are nil for the UEI: #{uei}"
          else
            puts "Mappings are available for UEI: #{uei}"
          end
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
        attr_reader :assignments

        def initialize(assignments: nil)
          if assignments.nil?
            @assignments = []
          else
            @assignments = assignments
          end
        end
      end

      class TranslationAssignment
        attr_reader :name, :type, :default, :value

        def initialize(name:, type:,default: nil, value:)
          @name = name
          @type = type
          @default = default || "Unknown"
          @value = value
        end
      end

      class TranslationValue
        attr_reader :type, :result, :values

        def initialize(type: nil, result: nil, values: nil)
          @type = type
          @result = result
          @values = values || []
        end
      end

      class TranslationValues
        attr_reader :type, :name, :matches, :result

        def initialize(type:, name:, matches:, result:)
          @type = type
          @name = name
          @matches = matches
          @result = result
          end
      end

        
    end
  end
end
