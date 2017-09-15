# frozen_string_literal: true
require 'rexml/document'

module Events
  include Chef::Mixin::ShellOut

  def event_file_included?(file, node)
    file = Regexp.last_match(1) if file =~ %r{^events/(.*)$}

    ecf = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", 'r')
    doc = REXML::Document.new ecf
    ecf.close

    !doc.elements["/events/event-file[text() = 'events/#{file}' and not(text()[2])]"].nil?
  end

  def uei_exists?(uei, node)
    exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/eventconf.xml", uei)
    # let's cheat!
    eventfile = shell_out("grep -l #{uei} #{node['opennms']['conf']['home']}/etc/events/*.xml")
    if eventfile.stdout != '' && eventfile.stdout.lines.to_a.length == 1
      return uei_in_file?(eventfile.stdout.chomp, uei)
    else
      # if multiple files match, only return if true since could be a regex false positive.
      eventfile.stdout.lines.each do |file|
        return true if uei_in_file?(file.chomp, uei)
      end
    end
    # okay, we'll do it right now, but this is slow.
    Chef::Log.debug("Starting dir search for uei #{uei}")
    Dir.foreach("#{node['opennms']['conf']['home']}/etc/events") do |file|
      next if file !~ /.*\.xml$/
      exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/events/#{file}", uei)
      break if exists
    end
    Chef::Log.debug("dir search for uei #{uei} complete")
    exists
  end

  def event_xpath(event)
    uei = event.uei || event.name
    event_xpath = "/events/event[uei/text() = '#{uei}'"
    unless event.mask.nil?
      event.mask.each do |m|
        if m.key?('mename') && m.key?('mevalue')
          event_xpath += " and mask/maskelement/mename[text() = '#{m['mename']}']"
          lastval = nil
          m['mevalue'].each do |value|
            event_xpath += " and mask/maskelement/mevalue[text() = '#{value}']/preceding-sibling::mename[text() = '#{m['mename']}']"
            lastval = value
          end
          event_xpath += " and not(mask/maskelement/mevalue[text() = '#{lastval}']/following-sibling::*)" unless lastval.nil?
        elsif m.key?('vbnumber') && m.key?('vbvalue')
          event_xpath += " and mask/varbind/vbnumber[text() = '#{m['vbnumber']}']"
          lastval = nil
          m['vbvalue'].each do |value|
            event_xpath += " and mask/varbind/vbvalue[text() = '#{value}']/preceding-sibling::vbnumber[text() = '#{m['vbnumber']}']"
            lastval = value
          end
          event_xpath += " and not(mask/varbind/vbvalue[text() = '#{lastval}']/following-sibling::*)" unless lastval.nil?
        end
      end
    end
    event_xpath += ']'
    Chef::Log.debug "event xpath is: #{event_xpath}"
    event_xpath
  end

  def event_in_file?(file, event)
    file = ::File.new(file, 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements[event_xpath(event)].nil?
  end

  # DANGER: this only checks that some event with this UEI exists in this file, while UEI + mask determines identity for opennms_event.
  # (useful in other resources, however, like opennms_threshold and opennms_expression).
  def uei_in_file?(file, uei)
    file = ::File.new(file, 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements["/events/event/uei[text() = '#{uei}']"].nil?
  end

  def event_file?(file, node)
    fn = "#{node['opennms']['conf']['home']}/etc/#{file}"
    eventfile = false
    if ::File.exist?(fn)
      file = ::File.new(fn, 'r')
      doc = REXML::Document.new file
      file.close
      eventfile = !doc.elements['/events'].nil?
    end
    eventfile
  end

  def event_changed?(event, node)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{event.file}", 'r')
    doc = REXML::Document.new file
    file.close
    event_el = doc.elements[event_xpath(event)]
    unless event.event_label.nil?
      el = event_el.elements['event-label'].text.to_s
      Chef::Log.debug "Event label equal? New: #{event.event_label}; Current: #{el}"
      return true unless event.event_label == el
    end
    unless event.descr.nil?
      descr = event_el.elements['descr'].texts.join('\n')
      Chef::Log.debug "Event descriptions equal? New: #{event.descr}; Current: #{descr}"
      return true unless event.descr == descr
    end
    unless event.logmsg.nil?
      logmsg = event_el.elements['logmsg'].texts.join('\n')
      Chef::Log.debug "Event logmsg equal? New: #{event.logmsg}; Current: #{logmsg}"
      return true unless event.logmsg == logmsg
    end
    unless event.logmsg_notify.nil?
      logmsg_notify = event_el.elements['logmsg/@notify'].value unless event_el.elements['logmsg/@notify'].nil?
      logmsg_notify = 'false' if logmsg_notify.to_s == ''
      Chef::Log.debug "Event logmsg notify equal? New: #{event.logmsg_notify}; Current #{logmsg_notify}"
      return true unless event.logmsg_notify.to_s == logmsg_notify
    end
    unless event.logmsg_dest.nil?
      logmsg_dest = event_el.elements['logmsg/@dest'].value unless event_el.elements['logmsg/@dest'].nil?
      Chef::Log.debug "Event logmsg dest equal? New: #{event.logmsg_dest}; Current #{logmsg_dest}"
      return true unless event.logmsg_dest.to_s == logmsg_dest.to_s
    end
    unless event.severity.nil?
      severity = event_el.elements['severity'].text.to_s
      Chef::Log.debug "Event severity equal? New: #{event.severity}; current #{severity}"
      return true unless event.severity == severity
    end
    unless event.operinstruct.nil?
      operinstruct = event_el.elements['operinstruct'].texts.join('\n') unless event_el.elements['operinstruct'].nil?
      Chef::Log.debug "Event operinstruct equal? New: #{event.operinstruct}; current #{operinstruct}"
      return true unless event.operinstruct == operinstruct
    end
    unless event.autoaction.nil?
      if event.autoaction.empty?
        unless event_el.elements['autoaction'].nil?
          Chef::Log.debug 'New resource autoaction is nil but exists currently.'
          return true
        end
      end
      if event_el.elements['autoaction'].nil?
        unless event.autoaction.nil?
          Chef::Log.debug 'Event autoaction present but nil in new resource.'
          return true
        end
      else
        autoactions = []
        event_el.elements.each('autoaction') do |aa|
          action = aa.texts.join('\n')
          state = aa.attributes['state'] || 'on'
          autoactions.push 'state' => state, 'action' => action
        end
        Chef::Log.debug "Autoactions equal? New: #{event.autoaction}, current #{autoactions}"
        return true unless event.autoaction == autoactions
      end
    end
    unless event.varbindsdecode.nil?
      if event.varbindsdecode.empty?
        unless event_el.elements['varbindsdecode'].nil?
          Chef::Log.debug 'Event varbindsdecode present but nil in new resource.'
          return true
        end
      end
      if event_el.elements['varbindsdecode'].nil?
        unless event.varbindsdecode.nil?
          Chef::Log.debug 'Event varbindsdecode not present but not nil in new resource.'
          return true
        end
      else
        varbindsdecodes = []
        event_el.elements.each('varbindsdecode') do |vbd|
          parmid = vbd.elements['parmid'].text.to_s
          decode = []
          vbd.elements.each('decode') do |d|
            varbindvalue = d.attributes['varbindvalue']
            varbinddecodedstring = d.attributes['varbinddecodedstring']
            decode.push 'varbindvalue' => varbindvalue, 'varbinddecodedstring' => varbinddecodedstring
          end
          varbindsdecodes.push 'parmid' => parmid, 'decode' => decode
        end
        Chef::Log.debug "varbindsdecodes equal? New: #{event.varbindsdecode}, current #{varbindsdecodes}"
        return true unless event.varbindsdecode == varbindsdecodes
      end
    end
    unless event.parameters.nil?
      if event.parameters.empty?
        unless event_el.elements['parameters'].nil?
          Chef::Log.debug 'Event parameters present but nil in new resource.'
          return true
        end
      end
      if event_el.elements['parameters'].nil?
        unless event.parameters.nil?
          Chef::Log.debug 'Event parameters not present but not nil in new resource.'
          return true
        end
      else
        parameters = []
        event_el.elements.each('parameters') do |parm|
          p = { 'name' => parm.attributes['name'], 'value' => parm.attributes['value'] }
          next unless Opennms::Helpers.major(node['opennms']['version']).to_i > 17 && parm.key?('expand')
          p['expand'] = if parm.attributes['expand'] == 'true'
                          true
                        else
                          false
                        end
        end
        Chef::Log.debug "parameters equal? New: #{event.parameters}, current #{parameters}"
        return true unless event.parameters == parameters
      end
    end
    if !event.tticket.nil? || event.tticket == false
      if event.tticket == false
        unless event_el.elements['tticket'].nil?
          Chef::Log.debug 'Event tticket not present but not nil in new resource.'
          return true
        end
      end
      if event_el.elements['tticket'].nil?
        unless event.tticket.nil?
          Chef::Log.debug 'Event tticket present but nil in new resource.'
          return true
        end
      else
        tticket_el = event_el.elements['tticket']
        tt_state = tticket_el.attributes['state'] || 'on'
        tt_info = tticket_el.texts.join('\n')
        tticket = { 'info' => tt_info, 'state' => tt_state }
        Chef::Log.debug "ttickets equal? New: #{event.tticket}, current #{tticket}"
        return true unless event.tticket == tticket
      end
    end
    unless event.forward.nil?
      if event.forward.empty?
        unless event_el.elements['forward'].nil?
          Chef::Log.debug 'Event forward present but nil in new resource.'
          return true
        end
      end
      if event_el.elements['forward'].nil?
        unless event.forward.nil?
          Chef::Log.debug 'Event forward not present but not nil in new resource.'
          return true
        end
      else
        forwards = []
        event_el.elements.each('forward') do |fwd|
          info = fwd.texts.join('\n')
          state = fwd.attributes['state'] || 'on'
          mechanism = fwd.attributes['mechanism']
          if state.nil? && mechanism.nil?
            forwards.push 'info' => info
          elsif state.nil? && !mechanism.nil?
            forwards.push 'info' => info, 'mechanism' => mechanism
          elsif !state.nil? && mechanism.nil?
            forwards.push 'info' => info, 'state' => state
          else
            forwards.push 'info' => info, 'state' => state, 'mechanism' => mechanism
          end
        end
        Chef::Log.debug "forwards equal? New: #{event.forward}, current #{forwards}"
        return true unless event.forward == forwards
      end
    end
    unless event.script.nil?
      if event.script.empty?
        unless event_el.elements['script'].nil?
          Chef::Log.debug 'Event script present but nil in new resource.'
          return true
        end
      end
      if event_el.elements['script'].nil?
        unless event.script.nil?
          Chef::Log.debug 'Event script not present but not nil in new resource.'
          return true
        end
      else
        scripts = []
        event_el.elements.each('script') do |s|
          name = s.texts.join('\n')
          language = s.attributes['language']
          scripts.push 'name' => name, 'language' => language
        end
        Chef::Log.debug "scripts equal? New: #{event.script}, current #{scripts}"
        return true unless event.script == scripts
      end
    end
    unless event.mouseovertext.nil?
      motext = event_el.elements['mouseovertext'].texts.join('\n') unless event_el.elements['mouseovertext'].nil?
      Chef::Log.debug "mouseovertext equal? New: #{event.mouseovertext}, current #{motext}"
      return true unless event.mouseovertext == motext
    end
    if !event.alarm_data.nil? || event.alarm_data == false
      ad_el = event_el.elements['alarm-data']
      if event.alarm_data == false
        unless event_el.elements['alarm-data'].nil?
          Chef::Log.debug 'Event alarm-data present but false in new resource.'
          return true
        end
      end
      if ad_el.nil?
        if !event.alarm_data.nil? && event.alarm_data != false
          Chef::Log.debug 'Event alarm-data not present but not nil in new resource.'
          return true
        end
      else
        alarm_type = ad_el.attributes['alarm-type'].to_i
        reduction_key = ad_el.attributes['reduction-key']
        clear_key = ad_el.attributes['clear-key']
        auto_clean = ad_el.attributes['auto-clean']
        if auto_clean == 'true'
          auto_clean = true
        elsif auto_clean == 'false'
          auto_clean = false
        end
        x733_alarm_type = ad_el.attributes['x733-alarm-type']
        x733_probable_cause = ad_el.attributes['x733-probable-cause']
        update_fields = []
        ad_el.elements.each('update-field') do |uf|
          fn = uf.attributes['field-name']
          uor = if uf.attributes['update-on-reduction'] == 'false'
                  false
                else
                  true
                end
          if uor.nil?
            update_fields.push 'field_name' => fn
          else
            update_fields.push 'field_name' => fn, 'update_on_reduction' => uor
          end
        end
        alarm_data = {}
        alarm_data['alarm_type'] = alarm_type
        alarm_data['reduction_key'] = reduction_key
        alarm_data['clear_key'] = clear_key unless clear_key.nil?
        alarm_data['auto_clean'] = auto_clean unless auto_clean.nil?
        alarm_data['x733_alarm_type'] = x733_alarm_type unless x733_alarm_type.nil?
        alarm_data['x733_probable_cause'] = x733_probable_cause unless x733_probable_cause.nil?
        alarm_data['update_fields'] = update_fields unless update_fields.empty?
        Chef::Log.debug "alarm data changed? new: #{event.alarm_data}; current: #{alarm_data}"
        return true unless event.alarm_data == alarm_data
      end
    end
    Chef::Log.debug 'Nothing in this event has changed!'
    false
  end

  def remove_file_from_eventconf(file, node)
    Chef::Log.debug "file is #{file}"
    if file =~ %r{^events/(.*)$}
      file = Regexp.last_match(1)
      Chef::Log.debug "file is now #{file}"
    end
    f = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
    contents = f.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote
    f.close

    doc.root.delete_element("/events/event-file[text() = 'events/#{file}']")
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
  end

  def add_file_to_eventconf(file, position, node)
    Chef::Log.debug "file is #{file}"
    if file =~ %r{^events/(.*)$}
      file = Regexp.last_match(1)
      Chef::Log.debug "file is now #{file}"
    end
    f = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
    contents = f.read
    doc = REXML::Document.new(contents, respect_whitespace: :all)
    doc.context[:attribute_quote] = :quote
    f.close

    events_el = doc.root.elements['/events']
    eventconf_el = REXML::Element.new('event-file')
    eventconf_el.add_text(REXML::CData.new("events/#{file}"))
    ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/ncs-component.events.xml']"]
    if position == 'top'
      ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/Translator.default.events.xml']"]
      events_el.insert_after(ref_ef_el, eventconf_el)
    else
      events_el.insert_before(ref_ef_el, eventconf_el)
    end
    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
  end
end
