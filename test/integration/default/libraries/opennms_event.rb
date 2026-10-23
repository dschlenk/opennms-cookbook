# frozen_string_literal: true

# Unified wrapper class to ensure nested hashes also support flexible lookup keys
class OpenNmsDynamicMash
  def initialize(hash)
    @data = hash || {}
  end

  def [](key)
    return if @data.nil?

    str_key = key.to_s
    val = @data[str_key] ||
          @data[str_key.downcase] ||
          @data[snake_case(str_key)] ||
          @data[hyphenate(str_key)] ||
          @data[camelize(str_key)]

    if val.is_a?(Hash)
      OpenNmsDynamicMash.new(val)
    elsif val.is_a?(Array)
      val.map { |item| item.is_a?(Hash) ? OpenNmsDynamicMash.new(item) : item }
    else
      val
    end
  end

  def method_missing(name, *_args)
    if name.to_s.match?(/^\d+$/)
      self[name.to_s.to_i]
    else
      self[name]
    end
  end

  def respond_to_missing?(*)
    true
  end

  def nil?
    @data.empty?
  end

  def empty?
    @data.empty?
  end

  private

  def snake_case(str)
    str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
  end

  def hyphenate(str)
    snake_case(str).tr('_', '-')
  end

  def camelize(str)
    components = str.split(/[_-]/)
    components.first.downcase + components[1..-1].map(&:capitalize).join('')
  end
end

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'

  attr_reader :raw_event_data

  def initialize(uei, _file = nil)
    payload = fetch_live_eventconf_json
    all_events = find_all_events(payload)
    @raw_event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
  end

  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  # Pass lookup down to our custom wrapper so nested dot paths work smoothly
  def method_missing(name, *args)
    return if raw_event_data.nil?

    OpenNmsDynamicMash.new(raw_event_data).send(name, *args)
  end

  def respond_to_missing?(*)
    true
  end

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

  def find_all_events(obj)
    events = []
    if obj.is_a?(Hash)
      obj.each do |k, v|
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
