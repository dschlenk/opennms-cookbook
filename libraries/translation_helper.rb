module Opennms
  module Cookbook
    module Translation
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

        
    end
  end
end
