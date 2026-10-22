# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :event_data

  # Horizon 35+ Capture the second argument, which legacy tests pass as a file path,
  # but allow it to act as a target mask signature or filter if a hash/string is passed.
  def initialize(uei, mask_or_file = nil)
    payload = fetch_live_eventconf_json

    events = payload['event'] || payload['events'] || payload || []
    events = [events] if events.is_a?(Hash)

    # Filter out all events matching our target UEI
    matched_ueis = events.select { |e| e['uei'] == uei }

    if matched_ueis.size > 1 && mask_or_file.is_a?(Hash)
      # If there are multiple matches and a mask structure is passed, look for the exact match
      @event_data = matched_ueis.find { |e| matches_mask?(e, mask_or_file) }
    end

    # Fallback: Default to the first found item if no specific mask matched or was passed
    @event_data ||= matched_ueis.first
  end

  def exist?
    !event_data.nil? && !event_data.empty?
  end

  def method_missing(name, *args)
    return super if event_data.nil?
    keys = name.to_s.split('.')
    result = keys.reduce(event_data) do |memo, key|
      memo.is_a?(Hash) ? memo[key] : nil
    end
    result.nil? ? super : result
  end

  def respond_to_missing?(method_name, include_private = false)
    keys = method_name.to_s.split('.')
    (!event_data.nil? && event_data.key?(keys.first)) || super
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

  # Helper method to evaluate structural mask matches against OpenNMS 35 API payloads
  def matches_mask?(event, target_mask)
    event_mask = event['mask'] || {}
    mask_elements = event_mask['maskelement'] || []

    target_mask.all? do |target_key, target_values|
      match = mask_elements.find { |me| me['mename'] == target_key.to_s }
      next false unless match

      actual_values = Array(match['mevalue'])
      (Array(target_values) & actual_values).any?
    end
  end
end
