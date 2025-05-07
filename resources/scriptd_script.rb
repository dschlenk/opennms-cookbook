include Opennms::XmlHelper

module Opennms
  module Cookbook
    module Scriptd
      class ScriptdConfigurationFile
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def self.read(file_path)
          return nil unless File.exist?(file_path)

          config = load_xml_file(file_path, 'scriptd-configuration', ScriptdConfig)
          new(config)
        end

        def write(file_path)
          save_xml_file(@config, file_path)
        end

        def add_script(name:, language:, script:, type:, uei:)
          @config.add_script(
            name: name,
            language: language,
            script: script,
            type: type,
            uei: uei
          )
        end

        def delete_script(name:, language:)
          @config.delete_script(
            name: name,
            language: language
          )
        end

        def get_script_body(name:, language:)
          script = @config.scripts.find do |s|
            s.name == name && s.language == language
          end
          script&.script
        end

        def script_exists?(name:, language:)
          @config.scripts.any? do |script|
            script.name == name && script.language == language
          end
        end
      end
    end
  end
end
