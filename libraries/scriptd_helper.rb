module Opennms
  module Cookbook
    module Scriptd
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

        def delete_engine(engine)
          @engine.delete_if do |e|
            e.language == engine[:language] &&
              e.class_name == engine[:class_name] &&
              e.extensions == engine[:extensions]
          end
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

        def delete_start_script(script)
          @start_script.delete_if do |s|
            s.language == script[:language] &&
              s.script == script[:script]
          end
        end

        def add_stop_script(script)
          @stop_script << script
        end

        def delete_stop_script(script)
          @stop_script.delete_if do |s|
            s.language == script[:language] &&
              s.script == script[:script]
          end
        end

        def add_reload_script(script)
          @reload_script << script
        end

        def delete_reload_script(script)
          @reload_script.delete_if do |s|
            s.language == script[:language] &&
              s.script == script[:script]
          end
        end

        def add_event_script(script)
          @event_script << script
        end

        def delete_event_script(script)
          @event_script.delete_if do |s|
            s.language == script[:language] &&
              s.script == script[:script] &&
              (script[:uei].nil? || s.uei == script[:uei])
          end
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
            script_elem = root.add_element('event-script')
            script_elem.attributes['language'] = script.language
            Array(script.uei).each do |uei|
              uei_elem = script_elem.add_element('uei')
              uei_elem.text = uei
            end
            script_body = script_elem.add_element('script')
            script_body.text = script.script
          end

          File.open(file_path, 'w') { |file| doc.write(file) }
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
          @uei = uei || []
          @language = language
          @script = script
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
