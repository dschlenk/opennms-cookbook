module Opennms
  module Cookbook
    module Scriptd
      module ScriptdTemplate
        def scriptd_resource_init
          scriptd_resource_create unless scriptd_resource_exist?
        end

        def scriptd_resource
          return unless scriptd_resource_exist?
          find_resource!(:template, "#{onms_etc}/scriptd-configuration.xml")
        end
        
        def ro_scriptd_resource_init
          ro_scriptd_resource_create unless ro_scriptd_resource_exist?
        end
        
        def ro_scriptd_resource
          return unless ro_scriptd_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/scriptd-configuration.xml")
        end
        
        private

        def scriptd_resource_exist?
          !find_resource(:template, "#{onms_etc}/scriptd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def scriptd_resource_create
          file = Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/scriptd-configuration.xml") do
              cookbook 'opennms'
              source 'scriptd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
            end
          end
        end
        
        def ro_scriptd_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/scriptd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_scriptd_resource_create
          file = Opennms::Cookbook::Scriptd::ScriptdConfigurationFile.read("#{onms_etc}/scriptd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/scriptd-configuration.xml") do
              cookbook 'opennms'
              source 'scriptd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end
      
      class ScriptdConfigurationFile
        include Opennms::XmlHelper
        attr_reader :scripts

        def initialize(scripts = nil)
          @scripts = scripts
        end

        def read!(file = 'scriptd-configuration.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          doc.root.each_element('/scriptd-configuration') do |scriptd_configuration|
        end

        def self.read(file = 'scriptd-configuration.xml')
          scriptedfile = ScriptdConfigurationFile.new
          scriptedfile.read!(file)
          scriptedfile
        end


      class ScriptdConfig
        attr_reader :engine, :start_script, :stop_script, :reload_script, :event_script, :transactional

        def initialize(engine: nil, start_script: nil, stop_script: nil, reload_script: nil, event_script: nil, transactional: nil)
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

      class Script
        attr_read :language, :script

        def initialize(language:,script:)
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
            @className.eql?(engine.className) &&
            @extensions.eql?(engine.extensions)
        end
      end

      class StartScript < Script
      end

      class StopScript < Script
      end

      class ReloadScript < Script
      end

      class EventScript < Script
        attr_reader :uei

        def initialize(uei: nil, language:, script:)
          @uei = if uei.nil?
                           []
                         else
                           uei
                         end
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
