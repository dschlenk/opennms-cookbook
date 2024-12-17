module Opennms
  module Cookbook
    module Notification
      module CommandsTemplate
        def nc_resource_init
          nc_resource_create unless nc_resource_exist?
        end

        def nc_resource
          return unless nc_resource_exist?
          find_resource!(:template, "#{onms_etc}/notificationCommands.xml")
        end

        private

        def nc_resource_exist?
          !find_resource(:template, "#{onms_etc}/notificationCommands.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def nc_resource_create
          file = Opennms::Cookbook::Notification::CommandsConfigFile.read("#{onms_etc}/notificationCommands.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/notificationCommands.xml") do
              cookbook 'opennms'
              source 'notificationCommands.xml.erb'
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

      module DestinationPathsTemplate
        def dp_resource_init
          dp_resource_create unless dp_resource_exist?
        end

        def dp_resource
          return unless dp_resource_exist?
          find_resource!(:template, "#{onms_etc}/destinationPaths.xml")
        end

        private

        def dp_resource_exist?
          !find_resource(:template, "#{onms_etc}/destinationPaths.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def dp_resource_create
          file = Opennms::Cookbook::Notification::DestinationPathConfigFile.read("#{onms_etc}/destinationPaths.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/destinationPaths.xml") do
              cookbook 'opennms'
              source 'destinationPaths.xml.erb'
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

      class CommandsConfigFile
        include Opennms::XmlHelper
        attr_reader :commands

        def initialize
          @commands = []
        end

        def read!(file = 'notificationCommands.xml')
          xmldoc_from_file(file).each_element('/notification-commands/command') do |command|
            arguments = [] unless command.elements['argument'].nil?
            command.each_element('argument') do |argument|
              arguments.push({ 'substitution' => xml_element_text(argument, 'substitution'),
                               'switch' => xml_element_text(argument, 'switch'),
                               'streamed' => argument.attributes['streamed'] }.compact)
            end
            @commands.push(Command.new(command_name: xml_element_text(command, 'name'),
                                       execute: xml_element_text(command, 'execute'),
                                       comment: xml_element_text(command, 'comment'),
                                       contact_type: xml_element_text(command, 'contact-type'),
                                       binary: s_to_boolean(command.attributes['binary']),
                                       arguments: arguments, service_registry: s_to_boolean(command.attributes['service-registry'])))
          end
        end

        def command(command_name:)
          command = @commands.select { |c| c.command_name.eql?(command_name) }
          return if command.empty?
          raise DuplicateCommand, "More than one command named #{command_name} found in config file." unless command.one?
          command.pop
        end

        def delete_command(command_name:)
          @commands.delete_if { |c| c.command_name.eql?(command_name) }
        end

        def self.read(file = 'notificationCommands.xml')
          ccf = CommandsConfigFile.new
          ccf.read!(file)
          ccf
        end
      end

      class Command
        attr_reader :command_name, :execute, :comment, :contact_type, :binary, :arguments, :service_registry

        def initialize(command_name:, execute:, comment: nil, contact_type: nil, binary: nil, arguments: nil, service_registry: nil)
          @command_name = command_name
          @execute = execute
          @comment = comment
          @contact_type = contact_type
          @binary = binary || false
          @arguments = arguments
          @service_registry = service_registry
        end

        def update(execute: nil, comment: nil, contact_type: nil, binary: nil, arguments: nil, service_registry: nil)
          @execute = execute unless execute.nil?
          @comment = comment unless comment.nil?
          @contact_type = contact_type unless contact_type.nil?
          @binary = binary unless binary.nil?
          @arguments = arguments unless arguments.nil?
          @service_registry = service_registry unless service_registry.nil?
        end
      end

      class DestinationPathConfigFile
        include Opennms::XmlHelper
        attr_reader :paths

        def initialize
          @paths = []
        end

        def read!(file = 'destinationPaths.xml')
          xmldoc_from_file(file).each_element('/destinationPaths/path') do |path|
            targets = [] unless path.elements['target'].nil?
            path.each_element('target') do |target|
              targets.push(Target.new(name: xml_element_text(target, 'name'), auto_notify: xml_element_text(target, 'autoNotify'), commands: xml_text_array(target, 'command'), interval: target.attributes['interval']))
            end
            escalates = [] unless path.elements['escalate'].nil?
            path.each_element('escalate') do |escalate|
              target = escalate.elements['target']
              escalates.push(Escalate.new(name: xml_element_text(target, 'name'), auto_notify: xml_element_text(target, 'autoNotify'), commands: xml_text_array(target, 'command'), interval: target.attributes['interval'], delay: escalate.attributes['delay']))
            end
            @paths.push(DestinationPath.new(path_name: path.attributes['name'],
                                            initial_delay: path.attributes['initial-delay'],
                                            targets: targets,
                                            escalates: escalates))
          end
        end

        def path(path_name:)
          path = @paths.select { |c| c.path_name.eql?(path_name) }
          return if path.empty?
          raise DuplicateDestinationPath, "More than one path named #{path_name} found in config file." unless path.one?
          path.pop
        end

        def delete_path(path_name:)
          @paths.delete_if { |c| c.path_name.eql?(path_name) }
        end

        def self.read(file = 'destinationPaths.xml')
          ccf = DestinationPathConfigFile.new
          ccf.read!(file)
          ccf
        end
      end

      class DestinationPath
        attr_reader :path_name, :initial_delay, :targets, :escalates

        def initialize(path_name:, initial_delay:, targets: nil, escalates: nil)
          @path_name = path_name
          @initial_delay = initial_delay
          @targets = targets || []
          @escalates = escalates || []
        end

        def target(target_name:)
          target = @targets.select { |c| c.name.eql?(target_name) }
          return if target.empty?
          raise DuplicateTarget, "More than one target named #{target_name} found in destination path #{@path_name} in config file." unless target.one?
          target.pop
        end

        def delete_target(target_name:)
          @targets.delete_if { |c| c.name.eql?(target_name) }
        end

        def escalate(escalate_name:)
          escalate = @escalates.select { |c| c.name.eql?(escalate_name) }
          return if escalate.empty?
          raise DuplicateEscalate, "More than one escalate named #{escalate_name} found in destination path #{@path_name} in config file." unless escalate.one?
          escalate.pop
        end

        def delete_escalate(escalate_name:)
          @escalates.delete_if { |c| c.name.eql?(escalate_name) }
        end

        def update(initial_delay: nil, targets: nil, escalates: nil)
          @initial_delay = initial_delay unless initial_delay.nil?
          @targets = targets unless targets.nil?
          @escalates = escalates unless escalates.nil?
        end
      end

      class Target
        attr_reader :name, :auto_notify, :commands, :interval

        def initialize(name:, auto_notify:, commands:, interval:)
          @name = name
          @auto_notify = auto_notify
          @commands = commands
          @interval = interval
        end

        def update(auto_notify:, commands:, interval:)
          @auto_notify = auto_notify unless auto_notify.nil?
          @commands = commands unless commands.nil?
          @interval = interval unless interval.nil?
        end
      end

      class Escalate < Target
        attr_reader :delay
        def initialize(name:, auto_notify:, commands:, interval:, delay:)
          super(name: name, auto_notify: auto_notify, commands: commands, interval: interval)
          @delay = delay
        end

        def update(auto_notify:, commands:, interval:, delay:)
          super(auto_notify: auto_notify, commands: commands, interval: interval)
          @delay = delay unless delay.nil?
        end
      end

      class DuplicateCommand < StandardError; end

      class DuplicateDestinationPath < StandardError; end

      class DuplicateTarget < StandardError; end

      class DuplicateEscalate < StandardError; end
    end
  end
end
