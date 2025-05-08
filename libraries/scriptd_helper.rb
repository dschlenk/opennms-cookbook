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

        def ro_scriptd_resource_exist?
          !find_resource(:template, 'RO /opt/opennms/etc/scriptd-configuration.xml').nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def scriptd_resource_create
          create_scriptd_template(
            path: '/opt/opennms/etc/scriptd-configuration.xml',
            delayed: :create
          )
        end

        def ro_scriptd_resource_create
          create_scriptd_template(
            path: 'RO /opt/opennms/etc/scriptd-configuration.xml',
            delayed: :nothing
          )
        end

        def create_scriptd_template(path:, delayed:)
          file = Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read('/opt/opennms/etc/scriptd-configuration.xml')
          file.config.write!

          with_run_context(:root) do
            declare_resource(:template, path) do
              cookbook 'opennms'
              source 'scriptd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file.config)
              action :nothing
              delayed_action delayed
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
          when :start
            add_start_script(StartScript.new(language: language, script: script))
          when :stop
            add_stop_script(StopScript.new(language: language, script: script))
          when :reload
            add_reload_script(ReloadScript.new(language: language, script: script))
          when :event
            add_event_script(EventScript.new(language: language, script: script, uei: uei))
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

        def eql?(other)
          self.class.eql?(other.class) &&
            @engine.eql?(other.engine) &&
            @start_script.eql?(other.start_script) &&
            @stop_script.eql?(other.stop_script) &&
            @reload_script.eql?(other.reload_script) &&
            @event_script.eql?(other.event_script) &&
            @transactional.eql?(other.transactional)
        end

        def write!(file = '/opt/opennms/etc/scriptd-configuration.xml')
          xml = Builder::XmlMarkup.new(indent: 2)
          xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
          xml.scriptd_configuration do |scriptd_config|
            @engine.each do |e|
              scriptd_config.engine(language: e.language, class_name: e.class_name, extensions: e.extensions)
            end
            @start_script.each do |s|
              scriptd_config.start_script(language: s.language, script: s.script)
            end
            @stop_script.each do |s|
              scriptd_config.stop_script(language: s.language, script: s.script)
            end
            @reload_script.each do |s|
              scriptd_config.reload_script(language: s.language, script: s.script)
            end
            @event_script.each do |e|
              scriptd_config.event_script(language: e.language, script: e.script) do |event|
                e.uei.each { |uei| event.uei(uei) }
              end
            end
          end
          File.write(file, xml.target!)
        end
      end

      class Script
        attr_reader :language, :script

        def initialize(language:, script:)
          @language = language
          @script = script
        end

        def eql?(other)
          self.class.eql?(other.class) &&
            @language.eql?(other.language) &&
            @script.eql?(other.script)
        end
      end

      class ScriptEngine
        attr_reader :language, :class_name, :extensions

        def initialize(language:, class_name:, extensions: nil)
          @language = language
          @class_name = class_name
          @extensions = extensions
        end

        def eql?(other)
          self.class.eql?(other.class) &&
            @language.eql?(other.language) &&
            @class_name.eql?(other.class_name) &&
            @extensions.eql?(other.extensions)
        end
      end

      class StartScript < Script; end
      class StopScript < Script; end
      class ReloadScript < Script; end

      class EventScript < Script
        attr_reader :uei

        def initialize(language:, script:, uei: nil)
          super(language: language, script: script)
          @uei = uei || []
        end

        def eql?(other)
          self.class.eql?(other.class) &&
            @uei.eql?(other.uei) &&
            @script.eql?(other.script) &&
            @language.eql?(other.language)
        end
      end
    end
  end
end
