# frozen_string_literal: true

# Helper to allow dot-notation access in InSpec tests
# e.g. opennms_event.uei, opennms_event.forward
class OpenNmsDynamicMash
  def initialize(hash)
    @hash = hash || {}
  end

  def method_missing(name, *_args)
    return if raw_event_data.nil?
    OpenNmsDynamicMash.new(raw_event_data).send(name, *args)
  end

  def respond_to_missing?(*)
    true
  end

  def [](key)
    @hash[key]
  end
end

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'
  attr_reader :raw_event_data, :event_data

  def initialize(uei, _file = nil)
    @uei = uei
    payload = fetch_live_eventconf_json
    all_events = find_all_events(payload)
    @raw_event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
    @event_data = @raw_event_data
  end

  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  def method_missing(name, *args)
    return nil if raw_event_data.nil?
    OpenNmsDynamicMash.new(raw_event_data).send(name, *args)
  end

  def respond_to_missing?(*)
    true
  end

  def fetch_live_eventconf
    inspec.command(
      'cat /opt/opennms/etc/events/chef.events.xml 2>/dev/null || ' \
      'cat /opt/opennms/etc/events/test.xml 2>/dev/null || ' \
      'cat /opt/opennms/etc/eventconf.xml 2>/dev/null'
    )
  end

  def fetch_live_eventconf_json
    cmd = fetch_live_eventconf

    if cmd.exit_status != 0 || cmd.stdout.empty?
      puts "ERROR: Could not read eventconf from disk. Exit: #{cmd.exit_status}"
      return {}
    end

    require 'nokogiri'
    doc = Nokogiri::XML(cmd.stdout)
    doc.remove_namespaces! # Critical for eventconf.xml xmlns

    events = doc.xpath('//event').map do |e|
      {
        'uei' => e.at_xpath('uei')&.text,
        'event-label' => e.at_xpath('event-label')&.text,
        'descr' => e.at_xpath('descr')&.text,
        'logmsg' => e.at_xpath('logmsg')&.text,
        'forward' => e.xpath('forward').map { |f| { 'mechanism' => f['mechanism'], 'state' => f['state'] } },
      }
    end

    { 'events' => events }
  rescue => e
    puts "ERROR: Failed to parse eventconf: #{e.message}"
    {}
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
    end
end
