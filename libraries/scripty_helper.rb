module Opennms
  module Cookbook
    module Scripty
      class ScriptdConfig
        attr_reader :engine, :start_script, :stop_script, :reload_script, :event_script"

        def initialize(engine: nil, start_script: nil, stop_script: nil, reload_script: nil, event_script: nil)
          @engine = if engine.nil?
                           []
                         else
                           engine
                         end
          @start_script = if start_script.nil?
                           []
                         else
                           start_script
                         end
          @stop_script = if stop_script.nil?
                           []
                         else
                           stop_script
                         end
                        
          @reload_script = if reload_script.nil?
                           []
                         else
                           reload_script
                         end
          @event_script = if event_script.nil?
                           []
                         else
                           event_script
                         end
          @transactional = transactional
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

      class ScriptEngine
        attr_reader :language, :className, :extensions

        def initialize(language:, className:, extensions: nil)
          @language = language
          @className = className
          @extensions = extensions
        end

        def eql?(engine)
          self.class.eql?(engine.class) &&
            @language.eql?(engine.language) &&
            @className.eql?(engine.className) &&
            @extensions.eql?(engine.extensions)
        end
      end

      class StartScript
        attr_reader :language

        def initialize(language: )
          @language = language
        end

        def eql?(start_script)
          self.class.eql?(start_script.class) &&
            @language.eql?(start_script.language)
        end
      end

      class StopScript
        attr_reader :language

        def initialize(language: )
          @language = language
        end

        def eql?(stop_script)
          self.class.eql?(stop_script.class) &&
            @language.eql?(stop_script.language)
        end
      end

      class ReloadScript
        attr_reader :language

        def initialize(language: )
          @language = language
        end

        def eql?(reload_script)
          self.class.eql?(reload_script.class) &&
            @language.eql?(reload_script.language)
        end
      end

      class EventScript
        attr_reader :uei, :name, :language

        def initialize(uei: nil, name: ,language: )
          @uei = if uei.nil?
                           []
                         else
                           uei
                         end
          @name = name
          @language = language
        end

        def eql?(event_script)
          self.class.eql?(event_script.class) &&
            @uei.eql?(event_script.uei) &&
            @name.eql?(event_script.name) &&
            @language.eql?(event_script.language)
        end
      end
