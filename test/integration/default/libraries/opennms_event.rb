# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :event_data

  def initialize(uei, file)
    source_name = file.sub(%r{^events/}, '').sub(/\.xml$/, '')

    payload = fetch_live_eventconf_json(source_name)
    events = payload['event'] || payload['events'] || []

    # if there's only 1 event, it might return a Hash instead of an Array
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

  def fetch_live_eventconf(source_name)
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8090/opennms/rest/eventconf/#{source_name}")
  end

  def fetch_live_eventconf_json(source_name)
    cmd = fetch_live_eventconf(source_name)
    return {} unless cmd.exit_status.zero?

    begin
      JSON.parse(cmd.stdout)
    rescue JSON::ParserError
      {}
    end
  end
end
