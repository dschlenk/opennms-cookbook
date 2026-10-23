# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :raw_event_data, :event_data

  def initialize(uei, _file = nil)
    payload = fetch_live_eventconf_json
    all_events = find_all_events(payload)

    # Trace the target payload node
    @raw_event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
    @event_data = @raw_event_data # Expose internal hash context for explicit match checks
  end

  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  def method_missing(name, *args)
    return if raw_event_data.nil?

    OpenNmsDynamicMash.new(raw_event_data).send(name, *args)
  end

  def respond_to_missing?(*)
    true
  end

  def fetch_live_eventconf
    # Targets the exact database-backed endpoint for Horizon 35+ validation matrices
    inspec.command("sleep 2 && curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/api/v2/eventconf")
  end

  def fetch_live_eventconf_json
    cmd = fetch_live_eventconf

    # Safe fallback logging via standard 'puts' statements inside InSpec layers
    if cmd.exit_status != 0 || cmd.stdout.empty?
      puts "ERROR: OpenNmsEventApi resource failed to contact REST endpoint. Exit: #{cmd.exit_status}"
      return {}
    end

    begin
      JSON.parse(cmd.stdout)
    rescue JSON::ParserError => e
      puts "ERROR: Failed to parse OpenNMS JSON schema stream: #{e.message}"
      {}
    end
  end

  private

  def find_all_events(obj)
    events = []
    if obj.is_a?(Hash)
      obj.each do |k, v|
        if %w(event events event_list eventList events_list).include?(k.to_s)
          v.is_a?(Array) ? events.concat(v) : events.push(v)
        else
          events.concat(find_all_events(v))
        end
      end
    elsif obj.is_a?(Array)
      obj.each { |item| events.concat(find_all_events(item)) }
    end
    events
  end
end
