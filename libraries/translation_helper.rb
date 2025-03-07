module Opennms
  module Cookbook
    module Translations
      module TranslationsTemplate
        def translation_resource_init
          translation_resource_create unless translation_resource_exist?
        end
        
        def translation_resource
          return unless translation_resource_exist?
          find_resource!(:template, "#{onms_etc}/translator-configuration.xml")
        end
        
        private

        def translations_resource_exist?
          !find_resource(:template, "#{onms_etc}/translator-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def translations_resource_create
          file = Opennms::Cookbook::Translations::TranslatorConfigurationFile.read("#{onms_etc}/translator-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/translator-configuration.xml") do
              cookbook 'opennms'
              source 'translator-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
            end
          end
        end
      end

      class TranslatorConfigurationFile
        include Opennms::XmlHelper
        attr_reader :specs

        def initialize(specs = nil)
          @specs = specs || []
        end

        def read!(file = 'translator-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          doc.root.each_element('/event-translator-configuration/translation/event-translation-spec') do |spec|
            spec_uei = spec.attributes['uei']
            mappings = []
            spec.each_element('mappings/mapping') do |mapping|
              preserve_snmp_data = mapping.attributes['preserve-snmp-data']
              assignments = []
              mapping.each_element('assignment') do |assignment|
                atype = assignment.attributes['type']
                aname = assignment.attributes['name']
                adefault = assignment.attributes['default']
                assignment.each_element('value') do |v|
                  avalue = parse_value(v)
                  # def initialize(name:, type:, default: nil, value:)
                  assignments.push TranslationAssignment.new(name: aname, type: atype, default: adefault, value: avalue)
                end
              end
              mappings.push TranslationMapping.new(assignments: assignments, preserve_snmp_data: preserve_snmp_data)
            end
            @specs.push TranslationSpec.new(uei: spec_uei, mappings: mappings)
          end
        end

        def self.read(file = 'translator-configuration.xml')
          translationfile = TranslatorConfigurationFile.new
          translationfile.read!(file)
          translationfile
        end

        private

        def parse_value(v)
          values = []
          v.each_element('value') do |v2|
            values.push parse_value(v2)
          end
          TranslationValue.new(type: v.attributes['type'], result: v.attributes['result'], matches: v.attributes['matches'], name: v.attributes['name'], values: values)
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
            assignments = []
          else
            assignments = assignments
          end
          @preserve_snmp_data = preserve_snmp_data
        end
      end

      class TranslationAssignment
        attr_reader :name, :type, :default, :value

        def initialize(name:, type:, default: nil, value:)
          @name = name
          @type = type
          @default = default
          @value = value
        end
      end

      class TranslationValue
        attr_reader :type, :result, :matches, :name, :values

        def initialize(type:, result:, matches: nil, name: nil, values: nil)
          @type = type
          @result = result
          @matches = matches
          @name = name
          @values = values || []
        end
      end
    end
  end
end
