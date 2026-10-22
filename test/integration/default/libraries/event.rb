# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'event'

  attr_reader :event_data
  def initialize(uei, file)
    source_name = file.sub(%r{^events/}, '').sub(/\.xml$/, '')

    payload = fetch_live_eventconf_json(source_name)
    events = payload['events'] || []

    @event_data = events.find { |e| e['uei'] == uei }
  end

  def exist?
    !event_data.nil? && !event_data.empty?
  end

  def method_missing(name)
    return nil if event_data.nil?
    event_data[name.to_s]
  end

  def fetch_live_eventconf(source_name)
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/rest/eventconf/#{source_name}")
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
