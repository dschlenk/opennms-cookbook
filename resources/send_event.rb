# UEI of the event to send
property :uei, String, default: 'uei.opennms.org/internal/reloadDaemonConfig'
# array of strings that are passed as command line arguments to
# the send-event.pl script. Assumes you've done the proper string
# escaping required
property :parameters, Array, callbacks: {
  'should be an array of shell-safe strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}

action_class do
  include Opennms::XmlHelper
end

action :run do
  converge_by("Run #{@new_resource}") do
    cmd = "#{onms_home}/bin/send-event.pl"
    unless new_resource.parameters.nil?
      new_resource.parameters.each do |p|
        cmd = "#{cmd} -p '#{p}'"
      end
    end
    cmd = "#{cmd} '#{new_resource.uei}'"
    if new_resource.parameters[0] == 'daemonName Eventd'
      cmd = "#{cmd}; #{onms_home}/bin/send-event.pl 'uei.opennms.org/internal/eventsConfigChange'"
    end unless new_resource.parameters.nil?
    bash "send_event_#{new_resource.name}" do
      code cmd
      user node['opennms']['username']
      cwd onms_home
    end
  end
end
