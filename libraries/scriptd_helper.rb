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
              class_name: e.attributes['className'],
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

        def delete_script(language:, script:, type:, uei: nil)
          case type.to_sym
          when :start
            @start_script.delete_if { |s| s.language == language && s.script == script }
          when :stop
            @stop_script.delete_if { |s| s.language == language && s.script == script }
          when :reload
            @reload_script.delete_if { |s| s.language == language && s.script == script }
          when :event
            @event_script.delete_if do |s|
              s.language == language &&
                s.script == script &&
                Array(s.uei).sort == Array(uei).sort
            end
          else
            raise ArgumentError, "Unsupported script type: #{type}"
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

        def write(file_path)
          doc = REXML::Document.new
          root = doc.add_element('scriptd-configuration')

          @engine.each do |engine|
            engine_elem = root.add_element('engine')
            engine_elem.attributes['language'] = engine.language
            engine_elem.attributes['class_name'] = engine.class_name
            engine_elem.attributes['extensions'] = engine.extensions
          end

          @start_script.each do |script|
            script_elem = root.add_element('start-script')
            script_elem.attributes['language'] = script.language
            script_elem.text = script.script
          end

          @stop_script.each do |script|
            script_elem = root.add_element('stop-script')
            script_elem.attributes['language'] = script.language
            script_elem.text = script.script
          end

          @reload_script.each do |script|
            script_elem = root.add_element('reload-script')
            script_elem.attributes['language'] = script.language
            script_elem.text = script.script
          end

          @event_script.each do |script|
            event_elem = root.add_element('event-script')
            event_elem.attributes['language'] = script.language
            script.uei.each { |uei| event_elem.add_element('uei').text = uei }
            event_elem.add_element('script').text = script.script
          end

          File.open(file_path, 'w') { |file| doc.write(file, 2) }
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
