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

      module NotificationsTemplate
        def notifs_resource_init
          notifs_resource_create unless notifs_resource_exist?
        end

        def notifs_resource
          return unless notifs_resource_exist?
          find_resource!(:template, "#{onms_etc}/notifications.xml")
        end

        private

        def notifs_resource_exist?
          !find_resource(:template, "#{onms_etc}/notifications.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def notifs_resource_create
          file = Opennms::Cookbook::Notification::NotificationsFile.read("#{onms_etc}/notifications.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/notifications.xml") do
              cookbook 'opennms'
              source 'notifications.xml.erb'
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

      module NotifdTemplate
        def notifd_resource_init
          notifd_resource_create unless notifd_resource_exist?
        end

        def notifd_resource
          return unless notifd_resource_exist?
          find_resource!(:template, "#{onms_etc}/notifd-configuration.xml")
        end

        private

        def notifd_resource_exist?
          !find_resource(:template, "#{onms_etc}/notifd-configuration.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def notifd_resource_create
          file = Opennms::Cookbook::Notification::NotifdConfigFile.read("#{onms_etc}/notifd-configuration.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/notifd-configuration.xml") do
              cookbook 'opennms'
              source 'notifd-configuration.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
              notifies :run, 'opennms_send_event[restart_Notifd]'
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

      class NotificationsFile
        include Opennms::XmlHelper
        attr_reader :notifs

        def initialize
          @notifs = []
        end

        def read!(file = 'notifications.xml')
          xmldoc_from_file(file).each_element('/notifications/notification') do |n|
            parameters = {} unless n.attributes['parameter'].nil?
            n.each_element('parameter') do |p|
              parameters[p.attributes['name']] = p.attributes['value']
            end
            @notifs.push(Notification.new(name: n.attributes['name'],
                                          status: n.attributes['status'],
                                          writeable: n.attributes['writeable'],
                                          uei: xml_element_text(n, 'uei'),
                                          description: xml_element_text(n, 'description'),
                                          rule: xml_element_text(n, 'rule'),
                                          strict_rule: s_to_boolean(xml_attr_value(n, 'rule/@strict')),
                                          destination_path: xml_element_text(n, 'destinationPath'),
                                          text_message: xml_element_multiline_blank_text(n, 'text-message'),
                                          subject: xml_element_text(n, 'subject'),
                                          numeric_message: xml_element_text(n, 'numeric-message'),
                                          event_severity: xml_element_text(n, 'event-severity'),
                                          parameters: parameters,
                                          vbname: xml_element_text(n, 'varbind/vbname'),
                                          vbvalue: xml_element_text(n, 'varbind/vbvalue')))
          end
        end

        def notification(name:)
          notif = @notifs.select { |c| c.name.eql?(name) }
          return if notif.empty?
          raise DuplicateNotification, "More than one notification named #{name} found in config file." unless notif.one?
          notif.pop
        end

        def delete_notification(name:)
          @notifs.delete_if { |c| c.name.eql?(name) }
        end

        def self.read(file = 'notifications.xml')
          ccf = NotificationsFile.new
          ccf.read!(file)
          ccf
        end
      end

      class Notification
        attr_reader :name, :status, :writeable, :uei, :description, :rule, :strict_rule, :destination_path, :text_message, :subject, :numeric_message, :event_severity, :parameters, :vbname, :vbvalue

        def initialize(name:, status:, uei:, rule:, destination_path:, text_message:, writeable: nil, description: nil, strict_rule: nil, subject: nil, numeric_message: nil, event_severity: nil, parameters: nil, vbname: nil, vbvalue: nil)
          @name = name
          @status = status
          @uei = uei
          @rule = rule
          @destination_path = destination_path
          @text_message = text_message
          @writeable = writeable
          @description = description
          @strict_rule = strict_rule
          @subject = subject
          @numeric_message = numeric_message
          @event_severity = event_severity
          @parameters = parameters
          @vbname = vbname
          @vbvalue = vbvalue
        end

        def update(status: nil, uei: nil, rule: nil, destination_path: nil, text_message: nil, writeable: nil, description: nil, strict_rule: nil, subject: nil, numeric_message: nil, event_severity: nil, parameters: nil, vbname: nil, vbvalue: nil)
          @status = status unless status.nil?
          @uei = uei unless uei.nil?
          @rule = rule unless rule.nil?
          @destination_path = destination_path unless destination_path.nil?
          @text_message = text_message unless text_message.nil?
          @writeable = writeable unless writeable.nil?
          @description = description unless description.nil?
          @strict_rule = strict_rule unless strict_rule.nil?
          @subject = subject unless subject.nil?
          @numeric_message = numeric_message unless numeric_message.nil?
          @event_severity = event_severity unless event_severity.nil?
          @parameters = parameters unless parameters.nil?
          @vbname = vbname unless vbname.nil?
          @vbvalue = vbvalue unless vbvalue.nil?
        end
      end

      class NotifdConfigFile
        include Opennms::XmlHelper
        attr_reader :status, :pages_sent, :next_notif_id, :next_user_notif_id, :next_group_id, :service_id_sql, :outstanding_notices_sql, :acknowledge_id_sql, :acknowledge_update_sql, :match_all, :email_address_command, :numeric_skip_resolution_prefix, :max_threads, :auto_acknowledge_alarm, :autoacks, :queues, :outage_calendars

        def initialize
          @autoacks = []
          @queues = []
          @outage_calendars = []
        end

        def read!(file = 'notifd-configuration.xml')
          root = xmldoc_from_file(file).root
          @status = root.attributes['status']
          @pages_sent = root.attributes['pages-sent']
          @next_notif_id = root.attributes['next-notif-id']
          @next_user_notif_id = root.attributes['next-user-notif-id']
          @next_user_notif_id = root.attributes['next-user-notif-id']
          @next_group_id = root.attributes['next-group-id']
          @service_id_sql = root.attributes['service-id-sql']
          @outstanding_notices_sql = root.attributes['outstanding-notices-sql']
          @acknowledge_id_sql = root.attributes['acknowledge-id-sql']
          @acknowledge_update_sql = root.attributes['acknowledge-update-sql']
          @match_all = s_to_boolean(root.attributes['match-all'])
          @email_address_command = root.attributes['email-address-command']
          @numeric_skip_resolution_prefix = s_to_boolean(root.attributes['numeric-skip-resolution-prefix'])
          @max_threads = root.attributes['max-threads']
          @auto_acknowledge_alarm = { 'resolution_prefix' => xml_attr_value(root, 'auto-acknowledge-alarm/@resolution-prefix'), 'notify' => xml_attr_value(root, 'auto-acknowledge-alarm/@notify'), 'ueis' => xml_text_array(root, 'auto-acknowledge-alarm/uei') }.compact unless root.elements['auto-acknowledge-alarm'].nil?
          root.each_element('auto-acknowledge') do |aa|
            @autoacks.push(AutoAck.new(uei: aa.attributes['uei'], acknowledge: aa.attributes['acknowledge'], resolution_prefix: aa.attributes['resolution-prefix'], notify: s_to_boolean(aa.attributes['notify']), matches: xml_text_array(aa, 'match')))
          end
          root.each_element('queue') do |q|
            init_params = {} unless q.elements['handler-class/init-params'].nil?
            q.each_element('handler-class/init-params') do |ip|
              init_params[xml_element_text(ip, 'param-name')] = xml_element_text(ip, 'param-value')
            end
            @queues.push({ 'queue_id' => xml_element_text(q, 'queue-id'), 'interval' => xml_element_text(q, 'interval'), 'handler_class' => xml_element_text(q, 'handler-class/name'), 'handler_class_init_params' => init_params }.compact)
          end
          @outage_calendars = xml_text_array(root, 'outage-calendar')
        end

        def autoack(uei:, acknowledge:)
          autoack = @autoacks.select { |c| c.uei.eql?(uei) && c.acknowledge.eql?(acknowledge) }
          return if autoack.empty?
          raise DuplicateAutoAck, "More than one autoack with UEI #{uei} and acknowledge #{acknowledge} found in config file." unless autoack.one?
          autoack.pop
        end

        def delete_autoack(uei:, acknowledge:)
          @autoacks.delete_if { |c| c.uei.eql?(uei) && c.acknowledge.eql?(acknowledge) }
        end

        def self.read(file = 'notifd-configuration.xml')
          ccf = NotifdConfigFile.new
          ccf.read!(file)
          ccf
        end
      end

      class AutoAck
        attr_reader :uei, :acknowledge, :resolution_prefix, :notify, :matches
        def initialize(uei:, acknowledge:, resolution_prefix:, matches:, notify: nil)
          @uei = uei
          @acknowledge = acknowledge
          @resolution_prefix = resolution_prefix
          @matches = matches
          @notify = notify
        end

        def update(resolution_prefix:, matches:, notify: nil)
          @resolution_prefix = resolution_prefix unless resolution_prefix.nil?
          @matches = matches unless matches.nil?
          @notify = notify unless notify.nil?
        end
      end

      class DuplicateCommand < StandardError; end

      class DuplicateDestinationPath < StandardError; end

      class DuplicateTarget < StandardError; end

      class DuplicateEscalate < StandardError; end

      class DuplicateNotification < StandardError; end

      class DuplicateAutoAck < StandardError; end
    end
  end
end
