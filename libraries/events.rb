require 'rexml/document'

module Events
  def event_file_included?(file, node)
    if file =~ /^events\/(.*)$/ 
      file = $1
    end

    ecf = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "r")
    doc = REXML::Document.new ecf
    ecf.close

    !doc.elements["/events/event-file[text() = 'events/#{file}' and not(text()[2])]"].nil?
  end
  def uei_exists?(uei, node)
    exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/eventconf.xml", uei)
    # let's cheat!
    eventfile = `grep -l #{uei} #{node['opennms']['conf']['home']}/etc/events/*.xml`
    if eventfile != '' && eventfile.lines.to_a.length == 1
      return uei_in_file?(eventfile.chomp, uei)
    else
      # if multiple files match, only return if true since could be a regex false positive.
      eventfile.lines.each do |file|
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
  def uei_in_file?(file, uei)
    file = ::File.new(file, "r")
    doc = REXML::Document.new file
    file.close
    !doc.elements["/events/event/uei[text() = '#{uei}']"].nil?
  end
  def is_event_file?(file, node)
    fn = "#{node['opennms']['conf']['home']}/etc/#{file}"
    eventfile = false
    if ::File.exists?(fn)
      file = ::File.new(fn, "r")
      doc = REXML::Document.new file
      file.close
      eventfile = !doc.elements["/events"].nil?
    end
    eventfile
  end
  def event_changed?(event, node)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{event.file}", "r")
    doc = REXML::Document.new file
    file.close
    event_el = doc.elements["/events/event[uei/text() = '#{event.uei}']"]
    mask_el = event_el.elements["mask"]
    unless event.mask.nil?
      if event.mask.size == 0
        Chef::Log.debug "Mask not defined in new resource."
        if mask_el.nil?
          Chef::Log.debug "new resource's mask is nil, as is current file."
        else
          Chef::Log.debug "Event mask in current file but nil in new resource."
          return true
        end
      end
      if mask_el.nil?
        Chef::Log.debug "Mask element does not exist in current."
        if event.mask.nil?
          Chef::Log.debug "Mask doesn't exist in current and is nil in new resource."
        else
          Chef::Log.debug "Event mask not present in current but is in new resource."
          return true
        end
      else
        Chef::Log.debug "Neither current nor new masks were nil."
        mask = []
        mask_el.elements.each('maskelement') do |maskelement|
          mename = maskelement.elements['mename'].text
          mevalues = []
          maskelement.elements.each('mevalue') do |mev|
            mevalues.push mev.text
          end
          mask.push 'mename' => mename.to_s, 'mevalue' => mevalues
        end
        Chef::Log.debug "Masks equal? New: #{event.mask}; Current: #{mask}"
        return true unless event.mask == mask
      end
    end
    unless event.event_label.nil?
      el = event_el.elements["event-label"].text.to_s
      Chef::Log.debug "Event label equal? New: #{event.event_label}; Current: #{el}"
      return true unless event.event_label == el
    end
    unless event.descr.nil?
      descr = event_el.elements["descr"].texts.join('\n')
      Chef::Log.debug "Event descriptions equal? New: #{event.descr}; Current: #{descr}"
      return true unless event.descr == descr
    end
    unless event.logmsg.nil?
      logmsg = event_el.elements["logmsg"].texts.join('\n')
      Chef::Log.debug "Event logmsg equal? New: #{event.logmsg}; Current: #{logmsg}"
      return true unless event.logmsg == logmsg
    end
    unless event.logmsg_notify.nil?
      logmsg_notify = event_el.elements["logmsg/@notify"].value unless event_el.elements["logmsg/@notify"].nil?
      logmsg_notify = 'false' if "#{logmsg_notify}" == ''
      Chef::Log.debug "Event logmsg notify equal? New: #{event.logmsg_notify}; Current #{logmsg_notify}"
      return true unless "#{event.logmsg_notify}" == logmsg_notify
    end
    unless event.logmsg_dest.nil?
      logmsg_dest = event_el.elements["logmsg/@dest"].value unless event_el.elements["logmsg/@dest"].nil?
      Chef::Log.debug "Event logmsg dest equal? New: #{event.logmsg_dest}; Current #{logmsg_dest}"
      return true unless "#{event.logmsg_dest}" == "#{logmsg_dest}"
    end
    unless event.severity.nil?
      severity = event_el.elements["severity"].text.to_s
      Chef::Log.debug "Event severity equal? New: #{event.severity}; current #{severity}"
      return true unless event.severity == severity
    end
    unless event.operinstruct.nil?
      operinstruct = event_el.elements['operinstruct'].texts.join('\n') unless event_el.elements['operinstruct'].nil?
      Chef::Log.debug "Event operinstruct equal? New: #{event.operinstruct}; current #{operinstruct}"
      return true unless event.operinstruct == operinstruct
    end
    unless event.autoaction.nil?
      if event.autoaction.size == 0
        unless event_el.elements['autoaction'].nil?
          Chef::Log.debug 'New resource autoaction is nil but exists currently.'
          return true;
        end
      end
      if event_el.elements["autoaction"].nil?
        unless event.autoaction.nil?
          Chef::Log.debug "Event autoaction present but nil in new resource."
          return true
        end
      else
        autoactions = []
        event_el.elements.each("autoaction") do |aa|
          action = aa.texts.join('\n')
          state = aa.attributes['state'] || 'on'
          autoactions.push 'state' => state, 'action' => action
        end
        Chef::Log.debug "Autoactions equal? New: #{event.autoaction}, current #{autoactions}"
        return true unless event.autoaction == autoactions
      end
    end
    unless event.varbindsdecode.nil?
      if event.varbindsdecode.size == 0
        unless event_el.elements['varbindsdecode'].nil?
          Chef::Log.debug "Event varbindsdecode present but nil in new resource."
          return true
        end
      end
      if event_el.elements["varbindsdecode"].nil?
        unless event.varbindsdecode.nil?
          Chef::Log.debug "Event varbindsdecode not present but not nil in new resource."
          return true
        end
      else
        varbindsdecodes = []
        event_el.elements.each("varbindsdecode") do |vbd|
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
      if event.parameters.size == 0
        unless event_el.elements['parameters'].nil?
          Chef::Log.debug "Event parameters present but nil in new resource."
          return true
        end
      end
      if event_el.elements["parameters"].nil?
        unless event.parameters.nil?
          Chef::Log.debug "Event parameters not present but not nil in new resource."
          return true
        end
      else
        parameters = []
        event_el.elements.each("parameters") do |parm|
          p = { 'name' => parm.attributes['name'], 'value' => parm.attributes['value'] }
          if node['opennms']['version_major'] > 17 && parm.has_key?('expand')
            if parm.attributes['expand'] == 'true'
              p['expand'] = true
            else
              p['expand'] = false
            end
          end
        end
        Chef::Log.debug "parameters equal? New: #{event.parameters}, current #{parameters}"
        return true unless event.parameters == parameters
      end
    end
    if !event.tticket.nil? || event.tticket == false
      if event.tticket == false
        unless event_el.elements['tticket'].nil?
          Chef::Log.debug "Event tticket not present but not nil in new resource."
          return true
        end
      end
      if event_el.elements["tticket"].nil?
        unless event.tticket.nil?
          Chef::Log.debug "Event tticket present but nil in new resource."
          return true
        end
      else
        tticket_el = event_el.elements["tticket"]
        tt_state = tticket_el.attributes['state'] || 'on'
        tt_info = tticket_el.texts.join('\n')
        tticket = {}
        tticket = {'info' => tt_info, 'state' => tt_state}
        Chef::Log.debug "ttickets equal? New: #{event.tticket}, current #{tticket}"
        return true unless event.tticket == tticket
      end
    end
    unless event.forward.nil?
      if event.forward.size == 0
        unless event_el.elements['forward'].nil?
          Chef::Log.debug "Event forward present but nil in new resource."
          return true
        end
      end
      if event_el.elements["forward"].nil?
        unless event.forward.nil?
          Chef::Log.debug "Event forward not present but not nil in new resource."
          return true
        end
      else
        forwards = []
        event_el.elements.each("forward") do |fwd|
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
      if event.script.size == 0
        unless event_el.elements['script'].nil?
          Chef::Log.debug "Event script present but nil in new resource."
          return true
        end
      end
      if event_el.elements["script"].nil?
        unless event.script.nil?
          Chef::Log.debug "Event script not present but not nil in new resource."
          return true
        end
      else
        scripts = []
        event_el.elements.each("script") do |s|
          name = s.texts.join('\n')
          language = s.attributes['language']
          scripts.push 'name' => name, 'language' => language
        end
        Chef::Log.debug "scripts equal? New: #{event.script}, current #{scripts}"
        return true unless event.script == scripts
      end
    end
    unless event.mouseovertext.nil?
      motext = event_el.elements["mouseovertext"].texts.join('\n') unless event_el.elements['mouseovertext'].nil?
      Chef::Log.debug "mouseovertext equal? New: #{event.mouseovertext}, current #{motext}"
      return true unless event.mouseovertext == motext
    end
    if !event.alarm_data.nil? || event.alarm_data == false
      ad_el = event_el.elements["alarm-data"]
      if event.alarm_data == false
        unless event_el.elements['alarm-data'].nil?
          Chef::Log.debug "Event alarm-data present but false in new resource."
          return true
        end
      end
      if ad_el.nil?
        unless event.alarm_data.nil?
          Chef::Log.debug "Event alarm-data not present but not nil in new resource."
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
          if uf.attributes['update-on-reduction'] == 'false'
            uor = false
          else
            uor = true
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
        if update_fields.size > 0
          alarm_data['update_fields'] = update_fields
        end
        Chef::Log.debug "alarm data changed? new: #{event.alarm_data}; current: #{alarm_data}"
        return true unless event.alarm_data == alarm_data
      end
    end
    Chef::Log.debug "Nothing in this event has changed!"
    false
  end

  def add_file_to_eventconf(file, position, node)
    Chef::Log.debug "file is #{file}"
    if file =~ /^events\/(.*)$/ 
      file = $1
      Chef::Log.debug "file is now #{file}"
    end
    f = ::File.new("#{node['opennms']['conf']['home']}/etc/eventconf.xml")
    contents = f.read
    doc = REXML::Document.new(contents, { :respect_whitespace => :all })
    doc.context[:attribute_quote] = :quote
    f.close

    events_el = doc.root.elements["/events"]
    eventconf_el = REXML::Element.new('event-file')
    eventconf_el.add_text(REXML::CData.new("events/#{file}"))
    ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/ncs-component.events.xml']"]
    if position == 'top'
      ref_ef_el = doc.root.elements["/events/event-file[text() = 'events/Translator.default.events.xml']"]
      events_el.insert_after(ref_ef_el, eventconf_el)
    else
      events_el.insert_before(ref_ef_el, eventconf_el)
    end
    out = ""
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    formatter.write(doc, out)
    ::File.open("#{node['opennms']['conf']['home']}/etc/eventconf.xml", "w"){ |f| f.puts(out) }
  end
end
