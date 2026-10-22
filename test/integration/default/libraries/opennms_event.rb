# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :event_data

  def initialize(uei, _file = nil)
    payload = fetch_live_eventconf_json

    events = payload['event'] || payload['events'] || payload || []
    events = [events] if events.is_a?(Hash)

    @event_data = events.find { |e| e['uei'] == uei }
  end

  def exist?
    !event_data.nil? && !event_data.empty?
  end

  # ===================================================================
  # Automatic Dot-Notation Traversal & Nil-Safe Property Fallback
  # ===================================================================
  def method_missing(name, *_args)
    return if event_data.nil?

    # Handle string dot-notation smoothly (e.g., 'alarmData.reductionKey')
    keys = name.to_s.split('.')

    keys.reduce(event_data) do |memo, key|
      if memo.is_a?(Hash)
        # Check standard key first, then fallback to lowercase/camelCase variants
        memo[key] || memo[key.downcase] || memo[camelize(key)]
      end
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    return true if event_data.nil?
    keys = method_name.to_s.split('.')
    event_data.key?(keys.first) || event_data.key?(keys.first.downcase) || super
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

  private

  def camelize(str)
    str.split('_').inject { |acc, elem| acc + elem.capitalize }
  end
end
