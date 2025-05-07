module Opennms
  module Cookbook
    module Scriptd
      module ScriptdTemplate
        def scriptd_resource_init
          scriptd_resource_create unless scriptd_resource_exist?
        end

        def scriptd_resource
          return unless scriptd_resource_exist?
          find_resource!(:template, '/opt/opennms/etc/scriptd-configuration.xml')
        end

        def ro_scriptd_resource_init
          ro_scriptd_resource_create unless ro_scriptd_resource_exist?
        end

        def ro_scriptd_resource
          return unless ro_scriptd_resource_exist?
          find_resource!(:template, 'RO /opt/opennms/etc/scriptd-configuration.xml')
        end

        private

        def scriptd_resource_exist?
          !find_resource(:template, '/opt/opennms/etc/scriptd-configuration.xml').nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def scriptd_resource_create
          file = Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read('/opt/opennms/etc/scriptd-configuration.xml')
          with_run_context(:root) do
            declare_resource(:template, '/opt/opennms/etc/scriptd-configuration.xml') do
              cookbook 'opennms'
              source 'scriptd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file.config)
              action :nothing
              delayed_action :create
            end
          end
        end

        def ro_scriptd_resource_exist?
          !find_resource(:template, 'RO /opt/opennms/etc/scriptd-configuration.xml').nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_scriptd_resource_create
          file = Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read('/opt/opennms/etc/scriptd-configuration.xml')
          with_run_context(:root) do
            declare_resource(:template, 'RO /opt/opennms/etc/scriptd-configuration.xml') do
              cookbook 'opennms'
              source 'scriptd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file.config)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class ScriptdConfigurationFile
        include Opennms::XmlHelper
        attr_reader :config

        def initialize
          @config = ScriptdConfig.new
        end

        def read!(file = 'scriptd-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          doc.elements.each('scriptd-configuration/engine') do |e|
            @config.add_engine(ScriptEngine.new(
              language: e.attributes['language'],
              class_name: e.attributes['class_name'],
              extensions: e.attributes['extensions']
            ))
          end

          doc.elements.each('scriptd-configuration/start-script') do |s|
            @config.add_start_script(StartScript.new(
              language: s.attributes['language'],
              script: s.text.strip
            ))
          end

          doc.elements.each('scriptd-configuration/stop-script') do |s|
            @config.add_stop_script(StopScript.new(
              language: s.attributes['language'],
              script: s.text.strip
            ))
          end

          doc.elements.each('scriptd-configuration/reload-script') do |s|
            @config.add_reload_script(ReloadScript.new(
              language: s.attributes['language'],
              script: s.text.strip
            ))
          end

          doc.elements.each('scriptd-configuration/event-script') do |e|
            ueis = []
            e.elements.each('uei') { |u| ueis << u.text.strip }
            @config.add_event_script(EventScript.new(
              uei: ueis,
              language: e.attributes['language'],
              script: e.elements['script']&.text&.strip
            ))
          end
        end

        def self.read(file = 'scriptd-configuration.xml')
          scriptedfile = ScriptdConfigurationFile.new
          scriptedfile.read!(file)
          scriptedfile
        end
      end

      class ScriptdConfig
        attr_reader :engine, :start_script, :stop_script, :reload_script, :event_script, :transactional

        def initialize(engine: nil, start_script: nil, stop_script: nil, reload_script: nil, event_script: nil, transactional: nil)
          @engine = engine || []
          @start_script = start_script || []
          @stop_script = stop_script || []
          @reload_script = reload_script || []
          @event_script = event_script || []
          @transactional = transactional
        end

        def add_engine(engine)
          if engine.is_a?(Hash)
            engine = ScriptEngine.new(
              language: engine[:language],
              class_name: engine[:class_name],
              extensions: engine[:extensions]
            )
          end
          @engine << engine
        end
        def add_script(language:, script:, type:, uei: nil)
          case type
            when start
              add_start_script(StartScript.new(language: language, script: script)
            when stop
              add_stop_script(StopScript.new(language: language, script: script)
            when reload
              add_reload_script(ReloadScript.new(language: language, script: script)
            when event
              add_event_script(EventScript.new(language: language, script: script, uei: uei)
          end
        end
        
        def add_start_script(script)
          @start_script << script
        end

        def add_stop_script(script)
          @stop_script << script
        end

        def add_reload_script(script)
          @reload_script << script
        end

        def add_event_script(script)
          @event_script << script
        end

        def eql?(scriptd_configuration)
          self.class.eql?(scriptd_configuration.class) &&
            @engine.eql?(scriptd_configuration.engine) &&
            @start_script.eql?(scriptd_configuration.start_script) &&
            @stop_script.eql?(scriptd_configuration.stop_script) &&
            @reload_script.eql?(scriptd_configuration.reload_script) &&
            @event_script.eql?(scriptd_configuration.event_script) &&
            @transactional.eql?(scriptd_configuration.transactional)
        end
      end

      class Script
        attr_reader :language, :script

        def initialize(language:, script:)
          @language = language
          @script = script
        end

        def eql?(start_script)
          self.class.eql?(start_script.class) &&
            @language.eql?(start_script.language) &&
            @script.eql?(start_script.script)
        end
      end

      class ScriptEngine
        attr_reader :language, :class_name, :extensions

        def initialize(language:, class_name:, extensions: nil)
          @language = language
          @class_name = class_name
          @extensions = extensions
        end

        def eql?(engine)
          self.class.eql?(engine.class) &&
            @language.eql?(engine.language) &&
            @class_name.eql?(engine.class_name) &&
            @extensions.eql?(engine.extensions)
        end
      end

      class StartScript < Script; end
      class StopScript < Script; end
      class ReloadScript < Script; end

      class EventScript < Script
        attr_reader :uei

        def initialize(language:, script:, uei: nil)
          @uei = uei || []
          @language = language
          @script = script
        end

        def eql?(event_script)
          self.class.eql?(event_script.class) &&
            @uei.eql?(event_script.uei) &&
            @script.eql?(event_script.script) &&
            @language.eql?(event_script.language)
        end
      end
    end
  end
end
