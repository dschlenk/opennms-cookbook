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

      class CommandsConfigFile
        include Opennms::XmlHelper
        attr_reader :commands

        def initialize
          @commands = []
        end

        def read!(file = 'notificationCommands.xml')
          xmldoc_from_file(file).each_element('/notification-commands/command') do |command|
            Chef::Log.warn("found command with name #{xml_element_text(command, 'name')}")
            arguments = [] unless command.elements['argument'].nil?
            command.each_element('argument') do |argument|
              arguments.push({ 'substitution' => xml_element_text(argument, 'substitution'),
                               'switch' => xml_element_text(argument, 'switch'),
                               'streamed' => argument.attributes['streamed'] }.compact)
            end
            Chef::Log.warn("has arguments #{arguments}")
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

      class DuplicateCommand < StandardError; end
    end
  end
end
