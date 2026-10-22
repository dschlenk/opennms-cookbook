# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :event_data

  # Horizon 35+ API no longer looks up by file/source_name.
  # We only need the UEI to find the event.
  def initialize(uei, _file = nil)
    payload = fetch_live_eventconf_json

    events = payload['event'] || payload['events'] || payload || []
    events = [events] if events.is_a?(Hash)

    @event_data = events.find { |e| e['uei'] == uei }
  end

  def exist?
    !event_data.nil? && !event_data.empty?
  end

  def method_missing(name)
    return if event_data.nil?
    event_data[name.to_s]
  end

  def respond_to_missing?(*)
    super
  end

  def fetch_live_eventconf
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8090/opennms/rest/eventconf")
  end

  def fetch_live_eventconf_json
    cmd = fetch_live_eventconf
    return {} unless cmd.exit_status.zero?

    begin
      JSON.parse(cmd.stdout)
    rescue JSON::ParserError
      {}
    end
  end
end
