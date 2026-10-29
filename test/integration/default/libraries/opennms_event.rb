# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'
  attr_reader :raw_event_data, :event_data

  def initialize(uei, file = nil)
    @uei = uei
    @source_name = file ? source_name_from_file(file) : nil
    payload = fetch_live_eventconf_via_api
    all_events = find_all_events(payload)
    @raw_event_data = all_events.find { |e| e.is_a?(Hash) && e['uei'] == uei }
    @event_data = @raw_event_data
  end

  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  def method_missing(name, *args, &block)
    return if raw_event_data.nil?
    OpenNmsDynamicMash.new(raw_event_data).send(name, *args, &block)
  end

  def respond_to_missing?(*)
    true
  end

  private

  def source_name_from_file(file)
    name = file.to_s
    name = name.sub(%r{^events/}, '')
    name.sub(/\.xml$/, '')
  end

  # Queries the real-time Horizon 35 API structure to retrieve the XML definitions
  def fetch_live_eventconf_via_api
    # Step 1: Look up sources using the filters API endpoint matching the recipe structure
    filter_url = "http://localhost:8980/opennms/api/v2/eventconf/filter/sources"
    filter_url += "?filter=#{@source_name}" if @source_name

    cmd_sources = inspec.command("curl -s -u admin:admin -X GET '#{filter_url}' -H 'Accept: application/json'")

    return {} if cmd_sources.exit_status != 0 || cmd_sources.stdout.empty?

    require 'json'
    begin
      ro = JSON.parse(cmd_sources.stdout) || {}
      page_items = ro['eventConfSourceList'] || []
      return {} if page_items.empty?

      compiled_events = []

      # Step 2: Stream the live XML definition out of the target source database block
      page_items.each do |source_object|
        download_url = "http://localhost:8980/opennms/api/v2/eventconf/sources/#{source_object['id']}/events/download"
        cmd_xml = inspec.command("curl -s -u admin:admin -X GET '#{download_url}' -H 'Accept: application/xml'")

        next if cmd_xml.exit_status != 0 || cmd_xml.stdout.empty? || cmd_xml.stdout == '<events xmlns="http://xmlns.opennms.org/xsd/eventconf"/>'

        compiled_events.concat(parse_xml_definitions(cmd_xml.stdout))
      end

      { 'events' => compiled_events }
    rescue StandardError => e
      puts "ERROR: Failed to handle OpenNMS API mapping lifecycle: #{e.message}"
      {}
    end
  end

  # Extracted parsing pipeline that mirrors the old document processing safely via Nokogiri
  def parse_xml_definitions(xml_string)
    require 'nokogiri'
    doc = Nokogiri::XML(xml_string)
    doc.remove_namespaces! # Strips out the xmlns tags so the XPath lookups work cleanly

    doc.xpath('//event').map do |e|
      {
        'uei' => e.at_xpath('uei')&.text,
        'event-label' => e.at_xpath('event-label')&.text,
        'descr' => e.at_xpath('descr')&.text,
        'logmsg' => e.at_xpath('logmsg')&.text,
        'severity' => e.at_xpath('severity')&.text,
        'forward' => e.xpath('forward').map { |f| { 'mechanism' => f['mechanism'], 'state' => f['state'] } },
        'script' => e.xpath('script').map { |s| { 'name' => s.text, 'language' => s['language'] } },
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

# Safe, crash-resistant dynamic wrapper class for nested hash tree lookups
class OpenNmsDynamicMash
  def initialize(hash)
    @hash = hash || {}
  end

  def method_missing(name, *args)
    string_key = name.to_s
    # Allows checking properties seamlessly matching both underscore or hyphen notation styles
    normalized_key = string_key.tr('_', '-')

    return @hash[string_key] if @hash.key?(string_key)
    return @hash[normalized_key] if @hash.key?(normalized_key)

    super
  end

  def respond_to_missing?(name, include_private = false)
    @hash.key?(name.to_s) || @hash.key?(name.to_s.tr('_', '-')) || super
  end

  def [](key)
    @hash[key]
  end
end
