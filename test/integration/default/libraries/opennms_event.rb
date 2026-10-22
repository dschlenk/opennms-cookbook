# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :event_data

  def initialize(uei, _file = nil)
    # Horizon 35+ Fix: Query the centralized endpoint listing natively using port 8980
    payload = fetch_live_eventconf_json

    # Dynamic scan: extract all sub-arrays or object trees regardless of OpenNMS wrapper structure
    all_events = find_all_events(payload)

    @event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
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
      elsif memo.is_a?(Array) && key.match?(/^\d+$/)
        memo[key.to_i]
      end
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    return true if event_data.nil?
    keys = method_name.to_s.split('.')
    event_data.key?(keys.first) || event_data.key?(keys.first.downcase) || super
  end

  # Horizon 35+: Use the correct default port 8980 and hit the modern /api/v2 namespace
  def fetch_live_eventconf
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/api/v2/eventconf")
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

  # Recursively crawl the dynamic payload map to collect any event elements safely
  def find_all_events(obj)
    events = []
    if obj.is_a?(Hash)
      obj.each do |k, v|
        # Horizon 35+ API encapsulates the internal properties under 'event' or 'events' loops
        if %w(event events event_list eventList).include?(k.to_s)
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
