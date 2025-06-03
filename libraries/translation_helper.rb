module Opennms
  module Cookbook
    module Translations
      module TranslationsTemplate
        def translation_resource_init
          translation_resource_create unless translation_resource_exist?
        end

        def ro_translation_resource_init
          ro_translation_resource_create unless ro_translation_resource_exist?
        end

        def translation_resource
          return unless translation_resource_exist?
          find_resource!(:template, "#{onms_etc}/translator-configuration.xml")
        end

        def ro_translation_resource
          return unless ro_translation_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/translator-configuration.xml")
        end

        private

        def translation_resource_exist?
          !find_resource(:template, "#{onms_etc}/translator-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_translation_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/translator-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def translation_resource_create
          file = Opennms::Cookbook::Translations::TranslatorConfigurationFile.read("#{onms_etc}/translator-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/translator-configuration.xml") do
              cookbook 'opennms'
              source 'translator-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                config: file,
                snmp_link_down: node['opennms']['translator']['snmp_link_down'],
                snmp_link_up: node['opennms']['translator']['snmp_link_up'],
                hyperic: node['opennms']['translator']['hyperic'],
                cisco_config_man: node['opennms']['translator']['cisco_config_man'],
                juniper_cfg_change: node['opennms']['translator']['juniper_cfg_change'],
                telemetry_clock_skew_detected: node['opennms']['translator']['telemetry_clock_skew_detected']
              )
              action :nothing
              delayed_action :create
            end
          end
        end

        def ro_translation_resource_create
          file = Opennms::Cookbook::Translations::TranslatorConfigurationFile.read("#{onms_etc}/translator-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/translator-configuration.xml") do
              cookbook 'opennms'
              source 'translator-configuration.xml.erb'
              path "#{Chef::Config[:file_cache_path]}/translator-configuration.xml"
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                config: file,
                snmp_link_down: node['opennms']['translator']['snmp_link_down'],
                snmp_link_up: node['opennms']['translator']['snmp_link_up'],
                hyperic: node['opennms']['translator']['hyperic'],
                cisco_config_man: node['opennms']['translator']['cisco_config_man'],
                juniper_cfg_change: node['opennms']['translator']['juniper_cfg_change'],
                telemetry_clock_skew_detected: node['opennms']['translator']['telemetry_clock_skew_detected']
              )
              action :nothing
              delayed_action :nothing
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
                avalue = parse_value(assignment.elements['value'])
                assignments.push TranslationAssignment.new(name: aname, type: atype, default: adefault, value: avalue)
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

        def event_translation_specs?(specs:)
          specs.each do |spec|
            return false unless @specs.any? { |s| s.eql?(spec) }
          end
          true
        end

        def delete_specs(specs:)
          @specs.delete_if do |s|
            specs.include?(s)
          end
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

        def initialize(uei:, mappings: nil)
          @uei = uei
          @mappings = mappings || []
        end

        def eql?(spec)
          self.class.eql?(spec.class) &&
            @uei.eql?(spec.uei) &&
            @mappings.eql?(spec.mappings)
        end

        def ==(spec)
          eql?(spec)
        end

        def to_s
          "Spec for UEI #{@uei} with mappings #{@mappings}."
        end

        def inspect
          to_s
        end
      end

      class TranslationMapping
        attr_reader :assignments, :preserve_snmp_data

        def initialize(assignments: nil, preserve_snmp_data: nil)
          @assignments = if assignments.nil?
                           []
                         else
                           assignments
                         end
          @preserve_snmp_data = preserve_snmp_data
        end

        def eql?(mapping)
          self.class.eql?(mapping.class) &&
            @assignments.eql?(mapping.assignments) &&
            @preserve_snmp_data.eql?(mapping.preserve_snmp_data)
        end

        def to_s
          "Mapping assignments #{@assignments}; preserve_snmp_data #{@preserve_snmp_data}"
        end

        def inspect
          to_s
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

        def eql?(assignment)
          self.class.eql?(assignment.class) &&
            @name.eql?(assignment.name) &&
            @type.eql?(assignment.type) &&
            @default.eql?(assignment.default) &&
            @value.eql?(assignment.value)
        end

        def to_s
          "Assignment name #{@name}; type #{@type}; default #{@default}; value #{@value}"
        end

        def inspect
          to_s
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

        def eql?(value)
          self.class.eql?(value.class) &&
            @type.eql?(value.type) &&
            @result.eql?(value.result) &&
            @matches.eql?(value.matches) &&
            @name.eql?(value.name) &&
            @values.eql?(value.values)
        end

        def to_s
          "Value name #{@name}; type #{@type}; result #{@result}; matches #{@matches}; values #{@values}"
        end

        def inspect
          to_s
        end
      end
    end
  end
end
