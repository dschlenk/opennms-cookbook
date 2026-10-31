# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'
  attr_reader :raw_event_data, :event_data

  def initialize(uei, file = nil)
    @uei = uei
    @source_variants = file ? [
      file.to_s,
      file.to_s.sub(%r{^events/}, ''),
      file.to_s.sub(%r{^events/}, '').sub(/\.xml$/, ''),
      "#{file.to_s.sub(%r{^events/}, '').sub(/\.events\.xml$/, '')}.events",
      file.to_s.split('/').last
    ].uniq : []

    payload = fetch_live_eventconf_via_api
    all_events = find_all_events(payload)
    @raw_event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
    @event_data = @raw_event_data
  end

  # This method is what InSpec uses for the 'exist' matcher
  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  def method_missing(name, *args, &block)
    # Explicitly catch the core InSpec matcher query methods so they don't break proxies
    return exist? if name == :exist? || name == :exists?
    return true if name == :empty? && raw_event_data.nil?
    return false if name == :empty?

    return nil if raw_event_data.nil?
    OpenNmsDynamicMash.new(raw_event_data).send(name, *args, &block)
  end

  def respond_to_missing?(name, include_private = false)
    %i[exist? exists? empty?].include?(name) || true
  end

  # Allow direct index lookup directly on the resource level (e.g. subject['uei'])
  def [](key)
    return nil if raw_event_data.nil?
    raw_event_data[key] || raw_event_data[key.to_s.tr('_', '-')]
  end

  private

  def fetch_live_eventconf_via_api
    compiled_events = []

    @source_variants.each do |variant|
      file_path = "/opt/opennms/etc/events/#{variant}.xml"
      cmd_file = inspec.command("cat '#{file_path}' 2>/dev/null")

      if cmd_file.exit_status.zero? && !cmd_file.stdout.empty?
        compiled_events.concat(parse_xml_definitions(cmd_file.stdout))
      end
    end

    if compiled_events.empty?
      global_xml = inspec.command("curl -s -u admin:admin -X GET 'http://localhost:8980/opennms/api/v2/eventconf' -H 'Accept: application/xml'")
      if global_xml.exit_status.zero? && !global_xml.stdout.empty? && !global_xml.stdout.include?('Not Found')
        compiled_events = parse_xml_definitions(global_xml.stdout)
      end
    end

    { 'events' => compiled_events }
  end

  def parse_xml_definitions(xml_string)
    require 'nokogiri'
    doc = Nokogiri::XML(xml_string)
    doc.remove_namespaces!

    doc.xpath('//event').map do |e|
      {
        'uei' => e.at_xpath('uei')&.text,
        'event-label' => e.at_xpath('event-label')&.text,
        'descr' => e.at_xpath('descr')&.text,
        'logmsg' => e.at_xpath('logmsg')&.text,
        'severity' => e.at_xpath('severity')&.text,
        'forward' => e.xpath('forward').map { |f| { 'mechanism' => f['mechanism'], 'state' => f['state'] } },
        'script' => e.xpath('script').map { |s| { 'name' => s.text, 'language' => s['language'] } },
        'parameter' => e.xpath('parameter').map { |p|
          h = { 'name' => p['name'], 'value' => p['value'] }
          h['expand'] = true if p['expand'] == 'true'
          h
        }
      }
    end
  rescue StandardError => e
    puts "ERROR: Failed to parse event definition block: #{e.message}"
    []
  end

  def find_all_events(obj)
    events = []
    if obj.is_a?(Hash)
      obj.each do |k, v|
        if %w[event events event_list eventList events_list].include?(k.to_s)
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

class OpenNmsDynamicMash
  def initialize(hash)
    @hash = hash || {}
  end

  def method_missing(name, *args)
    string_key = name.to_s

    if string_key.include?('.')
      parts = string_key.split('.')
      current = @hash
      parts.each do |part|
        normalized_part = part.tr('_', '-')
        if current.is_a?(Hash)
          current = current[part] || current[normalized_part]
        else
          return nil
        end
      end
      return current
    end

    normalized_key = string_key.tr('_', '-')
    return @hash[string_key] if @hash.key?(string_key)
    return @hash[normalized_key] if @hash.key?(normalized_key)

    super
  end

  def respond_to_missing?(name, include_private = false)
    name_str = name.to_s
    return true if name_str.include?('.')
    @hash.key?(name_str) || @hash.key?(name_str.tr('_', '-')) || super
  end

  def [](key)
    @hash[key]
  end
end
