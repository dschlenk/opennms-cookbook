# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event'
  attr_reader :raw_event_data, :event_data

  def initialize(uei, file = nil, mask = nil)
    @uei = uei
    @source_variants = build_source_variants(file)

    payload = fetch_live_eventconf_via_api
    all_events = find_all_events(payload)
    matching_events = all_events.select { |e| e.is_a?(Hash) && e['uei'] == uei }

    selected = if mask && !matching_events.empty?
                 matching_events.find { |e| e['mask'] == mask } || matching_events.last
               else
                 matching_events.last
               end

    @raw_event_data = selected
    @event_data = selected ? OpenNmsDynamicMash.new(selected) : nil
  end

  def exist?
    !raw_event_data.nil? && !raw_event_data.empty?
  end

  alias exists? exist?

  def empty?
    !exist?
  end

  def dig(*keys)
    event_data&.dig(*keys)
  end

  def [](key)
    event_data&.[](key)
  end

  def method_missing(name, *args, &block)
    return super if event_data.nil?

    if event_data.respond_to?(name)
      event_data.public_send(name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    (!event_data.nil? && event_data.respond_to?(name, include_private)) || super
  end

  private

  def build_source_variants(file)
    return [] unless file

    base = file.to_s.sub(%r{^events/}, '')
    [
      file.to_s,
      base,
      base.sub(/\.xml$/, ''),
      "#{base.sub(/\.events\.xml$/, '')}.events",
      file.to_s.split('/').last,
    ].uniq
  end

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
      mask_hash, vbs = parse_mask(e.at_xpath('mask'))
      logmsg_node = e.at_xpath('logmsg')
      logmsg_text = logmsg_node&.text&.strip
      logmsg_dest = logmsg_node&.[]('dest')
      logmsg_notify = logmsg_node && !logmsg_node['notify'].nil? ? (logmsg_node['notify'].downcase == 'true') : nil

      {
        'uei' => e.at_xpath('uei')&.text&.strip,
        'mask' => mask_hash,
        'varbinds' => vbs,
        'priority' => e.at_xpath('priority')&.text&.strip&.to_i,
        'event_label' => e.at_xpath('event-label')&.text&.strip,
        'descr' => e.at_xpath('descr')&.text&.strip,
        'logmsg' => logmsg_text ? OpenNmsLogmsg.new(logmsg_text, logmsg_dest, logmsg_notify) : nil,
        'logmsg_dest' => logmsg_dest,
        'logmsg_notify' => logmsg_notify,
        'severity' => e.at_xpath('severity')&.text&.strip,
        'mouseovertext' => e.at_xpath('mouseovertext')&.text&.strip,
        'operinstruct' => e.at_xpath('operinstruct')&.text&.strip,
        'loggroup' => e.at_xpath('loggroup')&.text&.strip,
        'alarm_data' => parse_alarm_data(e.at_xpath('alarm-data')),
        'autoacknowledge' => parse_text_state(e.at_xpath('autoacknowledge')),
        'tticket' => parse_text_state(e.at_xpath('tticket')),
        'collection_group' => parse_collection_groups(e),
        'filters' => parse_filters(e),
        'forward' => e.xpath('forward').map { |f| { 'mechanism' => f['mechanism'], 'state' => f['state'], 'info' => f.text.strip } },
        'autoaction' => e.xpath('autoaction').map { |a| { 'action' => a.text.strip, 'state' => a['state'] } },
        'operaction' => e.xpath('operaction').map { |o| { 'action' => o.text.strip, 'state' => o['state'], 'menutext' => o['menutext'] } },
        'script' => e.xpath('script').map { |s| { 'name' => s.text.strip, 'language' => s['language'] } },
        'varbindsdecode' => parse_varbinds_decode(e),
        'parameter' => parse_parameters(e),
      }
    end
  rescue StandardError => e
    puts "Warn: Failed to parse event definition block: #{e.message}"
    []
  end

  def parse_mask(mask_node)
    return [nil, []] unless mask_node

    mes = mask_node.xpath('maskelement').map do |me|
      {
        'mename' => me.at_xpath('mename')&.text&.strip,
        'mevalue' => me.xpath('mevalue').map { |v| v.text.strip },
      }
    end

    vbs = mask_node.xpath('varbind').map do |vb|
      {
        'vbnumber' => vb.at_xpath('vbnumber')&.text&.strip,
        'vbvalue' => vb.xpath('vbvalue').map { |v| v.text.strip },
      }
    end

    [{ 'maskelement' => mes, 'varbind' => vbs }, vbs]
  end

  def parse_alarm_data(ad)
    return unless ad

    data = {
      'reduction_key' => ad['reduction-key'],
      'alarm_type' => ad['alarm-type'].to_i,
      'auto_clean' => ad['auto-clean'] == 'true',
    }
    data['clear_key'] = ad['clear-key'] if ad['clear-key']
    data
  end

  def parse_text_state(node)
    node ? { 'info' => node.text.strip, 'state' => node['state'] } : nil
  end

  def parse_collection_groups(event_node)
    event_node.xpath('collectionGroup').map do |cg|
      g = {
        'name' => cg['name'],
        'collections' => cg.xpath('collection').map do |col|
          c = { 'name' => col['name'] }
          c['rename'] = col['rename'] if col['rename']
          c['type'] = col['type'] if col['type']
          pvs = col.xpath('paramValue')
          unless pvs.empty?
            c['param_values'] = pvs.each_with_object({}) do |pv, h|
              val = pv['value']
              h[pv['key']] = val =~ /^\d+$/ ? val.to_i : val.to_f
            end
          end
          c
        end,
      }
      g['resource_type'] = cg['resourceType'] if cg['resourceType']
      g['instance'] = cg['instance'] if cg['instance']

      rrd = cg.at_xpath('rrd')
      if rrd
        g['rrd'] = {
          'step' => rrd['step'].to_i,
          'rra' => rrd.xpath('rra').map { |r| r.text.strip },
        }
        g['rrd']['heartbeat'] = rrd['heartBeat'].to_i if rrd['heartBeat']
      end
      g
    end
  end

  def parse_filters(event_node)
    event_node.xpath('filters/filter').map do |f|
      {
        'eventparm' => f['eventparm'],
        'pattern' => f['pattern'],
        'replacement' => f['replacement'],
      }
    end
  end

  def parse_varbinds_decode(event_node)
    event_node.xpath('varbindsdecode').map do |v|
      parmid_el = v.at_xpath('parmid') || v.at_xpath('parmIds') || v.at_xpath('parmids')
      parmid_val = parmid_el ? parmid_el.text.strip : (v['parmid'] || v['parmIds'] || v['parmids'])

      {
        'parmid' => parmid_val,
        'decode' => v.xpath('decode').map do |d|
          {
            'varbindvalue' => d['varbindvalue'] || d['varbindValue'] || d.at_xpath('varbindvalue')&.text || d.at_xpath('varbindValue')&.text,
            'varbinddecodedstring' => d['varbinddecodedstring'] || d['varbindDecodedString'] || d.at_xpath('varbinddecodedstring')&.text || d.at_xpath('varbindDecodedString')&.text,
          }
        end,
      }
    end
  end

  def parse_parameters(event_node)
    event_node.xpath('parameter').map do |p|
      h = { 'name' => p['name'], 'value' => p['value'] }
      h['expand'] = true if p['expand'] == 'true'
      h
    end
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

class OpenNmsDynamicMash < Hash
  KEY_ALIASES = {
    'eventfilter' => 'filters',
  }.freeze

  def initialize(hash = {})
    super()
    (hash || {}).each do |k, v|
      self[k] = v
    end
  end

  def []=(key, val)
    super(normalize_key(key), wrap(val))
  end

  def [](key)
    super(normalize_key(key))
  end

  def key?(key)
    super(normalize_key(key))
  end
  alias has_key? key?
  alias include? key?
  alias member? key?

  def fetch(key, *args, &block)
    super(normalize_key(key), *args, &block)
  end

  def dig(*keys)
    current = self
    keys.each do |k|
      if current.is_a?(Hash)
        current = current[k]
      elsif current.is_a?(Array) && k.is_a?(Integer)
        current = current[k]
      else
        return nil
      end
    end
    current
  end

  def ==(other)
    if other.is_a?(Hash)
      super(self.class.new(other))
    else
      super
    end
  end

  def method_missing(name, *args)
    string_key = name.to_s
    return dig(*string_key.split('.')) if string_key.include?('.')

    norm = normalize_key(string_key)
    return self[norm] if key?(norm)

    super
  end

  def respond_to_missing?(name, include_private = false)
    string_key = name.to_s
    return true if string_key.include?('.')

    key?(normalize_key(string_key)) || super
  end

  private

  def wrap(val)
    case val
    when self.class
      val
    when Hash
      self.class.new(val)
    when Array
      val.map { |item| wrap(item) }
    else
      val
    end
  end

  def normalize_key(key)
    snaked = key.to_s
                .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                .tr('-', '_')
                .downcase
    KEY_ALIASES.fetch(snaked, snaked)
  end
end

class OpenNmsLogmsg < String
  def initialize(text, dest = nil, notify = nil)
    super(text.to_s)
    @meta = {}
    @meta['content'] = text.to_s unless text.nil?
    @meta['dest'] = dest unless dest.nil?
    @meta['notify'] = notify unless notify.nil?
  end

  def include?(other)
    if other.is_a?(Hash)
      other.all? { |k, v| @meta[k.to_s] == v }
    else
      super(other)
    end
  end

  def [](key)
    case key
    when Symbol
      @meta[key.to_s]
    when String
      @meta.key?(key) ? @meta[key] : super
    else
      super
    end
  end
end
