include Events
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("File specified '#{@current_resource.file}' exists but is not an eventconf file!") if current_resource.file_exists && !current_resource.is_event_file
  if !@current_resource.file_exists
    create_event_file # also adds to eventconf
  elsif !event_file_included?(@current_resource.file, node)
    add_file_to_eventconf(@current_resource.file, 'bottom', node)
  end
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create/Update #{ @new_resource }") do
      create_event
      new_resource.updated_by_last_action(true)
    end
  end
end

action :create_if_missing do
  Chef::Application.fatal!("File specified '#{@current_resource.file}' exists but is not an eventconf file!") if current_resource.file_exists && !current_resource.is_event_file
  if !@current_resource.file_exists
    create_event_file # also adds to eventconf
  elsif !event_file_included?(@current_resource.file, node)
    add_file_to_eventconf(@current_resource.file, 'bottom', node)
  end
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_event
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsEvent.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.uei(@new_resource.uei || @new_resource.name)
  @current_resource.file(@new_resource.file)
  @current_resource.mask(@new_resource.mask)
  @current_resource.event_label(@new_resource.event_label)
  @current_resource.descr(@new_resource.descr)
  @current_resource.logmsg(@new_resource.logmsg)
  @current_resource.logmsg_dest(@new_resource.logmsg_dest)
  @current_resource.logmsg_notify(@new_resource.logmsg_notify)
  @current_resource.severity(@new_resource.severity)
  @current_resource.operinstruct(@new_resource.operinstruct)
  @current_resource.autoaction(@new_resource.autoaction)
  @current_resource.varbindsdecode(@new_resource.varbindsdecode)
  @current_resource.tticket(@new_resource.tticket)
  @current_resource.forward(@new_resource.forward)
  @current_resource.script(@new_resource.script)
  @current_resource.mouseovertext(@new_resource.mouseovertext)
  @current_resource.alarm_data(@new_resource.alarm_data)

  if ::File.exists?("#{node['opennms']['conf']['home']}/etc/#{@current_resource.file}")
    @current_resource.file_exists = true
    if is_event_file?(@current_resource.file, node)
      @current_resource.is_event_file = true
      if uei_in_file?("#{node['opennms']['conf']['home']}/etc/#{@current_resource.file}", @current_resource.uei)
        @current_resource.exists = true
        if event_changed?(@current_resource, node)
          @current_resource.changed = true
        end
      end
    end
  end
end


private

def create_event_file
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new
  events_el = doc.add_element 'events'
  events_el.add_namespace("http://xmlns.opennms.org/xsd/eventconf")
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}", "w"){ |file| file.puts(out) }
  # include in eventconf.xml
  add_file_to_eventconf(new_resource.file, 'bottom', node)
end

def create_event
  new_resource.uei = new_resource.name if new_resource.uei.nil?
  # make sure event file is included in main eventconf
  if !event_file_included?(new_resource.file, node)
    add_file_to_eventconf(new_resource.file, 'bottom', node)
  end
  Chef::Log.debug "Adding uei '#{new_resource.uei}' to '#{new_resource.file}'."
  
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}", "r")
  doc = REXML::Document.new file
  file.close
  doc.context[:attribute_quote] = :quote
  unless event_el = doc.root.elements["/events/event/uei[text() = '#{new_resource.uei}']"].nil?
    doc.root.elements.delete("/events/event[uei/text() = '#{new_resource.uei}']")
  end
  event_el = doc.root.add_element 'event'
  if !new_resource.mask.nil?
    mask_el = event_el.add_element 'mask'
    new_resource.mask.each do |mask|
      me_el = mask_el.add_element 'maskelement'
      name_el = me_el.add_element 'mename'
      name_el.add_text mask['mename']
      mask['mevalue'].each do |value|
        vel = me_el.add_element 'mevalue'
        vel.add_text value
      end
    end
  end
  uei_el = event_el.add_element 'uei'
  uei_el.add_text(new_resource.uei)
  el_el = event_el.add_element 'event-label'
  el_el.add_text(REXML::CData.new(new_resource.event_label))
  if !new_resource.snmp.nil?
    # TODO
  end
  descr_el = event_el.add_element 'descr'
  descr_el.add_text(REXML::CData.new(new_resource.descr))
  logmsg_el = event_el.add_element 'logmsg'
  logmsg_el.attributes['notify'] = 'true' if new_resource.logmsg_notify == true
  logmsg_el.attributes['dest'] = new_resource.logmsg_dest
  logmsg_el.add_text(REXML::CData.new(new_resource.logmsg))
  sev_el = event_el.add_element 'severity'
  sev_el.add_text(new_resource.severity)
  if !new_resource.correlation.nil?
     # TODO
  end
  if !new_resource.operinstruct.nil?
    oi_el = event_el.add_element 'operinstruct'
    oi_el.add_text(REXML::CData.new(new_resource.operinstruct))
  end
  if !new_resource.autoaction.nil?
    new_resource.autoaction.each do |autoaction|
      aa_el = event_el.add_element 'autoaction'
      if autoaction['state'] == 'off'
        aa_el.attributes['state'] = 'off'
      end
      aa_el.add_text(REXML::CData.new(autoaction['action']))
    end
  end
  if !new_resource.varbindsdecode.nil?
    new_resource.varbindsdecode.each do |vbd|
      vbd_el = event_el.add_element 'varbindsdecode'
      parmid_el = vbd_el.add_element 'parmid'
      parmid_el.add_text(vbd['parmid'])
      vbd['decode'].each do |decode|
        vbd_el.add_element 'decode', {'varbindvalue' => decode['varbindvalue'], 'varbinddecodedstring' => decode['varbinddecodedstring']}
      end
    end
  end
  if !new_resource.operaction.nil?
    # TODO
  end
  if !new_resource.autoacknowledge.nil?
    # TODO
  end
  if !new_resource.loggroup.nil?
    # TODO
  end
  if !new_resource.tticket.nil?
    tt_el = event_el.add_element 'tticket'
    tt_el.attributes['state'] = 'off' if new_resource.tticket['state'] == 'off'
    tt_el.add_text(REXML::CData.new(new_resource.tticket['info']))
  end
  if !new_resource.forward.nil?
    new_resource.forward.each do |forward|
      fw_el = event_el.add_element 'forward'
      fw_el.attributes['state'] = 'off' if forward['state'] == 'off'
      fw_el.attributes['mechanism'] = forward['mechanism'] if !forward['mechanism'].nil?
      fw_el.add_text(REXML::CData.new(forward['info']))
    end
  end
  if !new_resource.script.nil?
    new_resource.script.each do |script|
      script_el = event_el.add_element 'script', {'language' => script['language']}
      script_el.add_text(script['name'])
    end
  end
  if !new_resource.mouseovertext.nil?
    mot_el = event_el.add_element 'mouseovertext'
    mot_el.add_text(REXML::CData.new(new_resource.mouseovertext))
  end
  if !new_resource.alarm_data.nil?
    ad = new_resource.alarm_data
    ad_el = event_el.add_element 'alarm-data', {'reduction-key' => ad['reduction_key'], 'alarm-type' => ad['alarm_type']}
    ad_el.attributes['clear-key'] = ad['clear_key'] if ad.has_key? 'clear_key'
    ad_el.attributes['auto-clean'] = ad['auto_clean'] if ad.has_key? 'auto_clean'
    ad_el.attributes['x733-alarm-type'] = ad['x733_alarm_type'] if ad.has_key? 'x733_alarm_type'
    ad_el.attributes['x733-probable-cause'] = ad['x733_probable_cause'] if ad.has_key? 'x733_probable_cause'
    if ad.has_key? 'update_fields'
      ad['update_fields'].each do |field|
        uf_el = ad_el.add_element 'update-field', {'field-name' => field['field_name']}
        uf_el.attributes['update-on-reduction'] = 'false' if field.has_key? 'update_on_reduction' && field['update_on_reduction'] == false
      end
    end
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}", "w"){ |file| file.puts(out) }
end
