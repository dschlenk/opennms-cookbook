# frozen_string_literal: true
include Events
def whyrun_supported?
  true
end

use_inline_resources

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_event
    end
  else
    Chef::Log.info("#{new_resource} doesn't exist - nothing to do.")
  end
end

action :create do
  Chef::Application.fatal!("File specified '#{@current_resource.file}' exists but is not an eventconf file!") if current_resource.file_exists && !current_resource.is_event_file
  if !@current_resource.file_exists
    create_event_file # also adds to eventconf
  elsif !event_file_included?(@current_resource.file, node)
    add_file_to_eventconf(@current_resource.file, 'bottom', node)
  end
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and not changed - nothing to do."
  else
    Chef::Log.info "#{@new_resource} changed or updating."
    converge_by("Create/Update #{@new_resource}") do
      create_event
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
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_event
    end
  end
end

# rubocop:disable Metrics/BlockNesting
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
  @current_resource.parameters(@new_resource.parameters)
  @current_resource.tticket(@new_resource.tticket)
  @current_resource.forward(@new_resource.forward)
  @current_resource.script(@new_resource.script)
  @current_resource.mouseovertext(@new_resource.mouseovertext)
  @current_resource.alarm_data(@new_resource.alarm_data)

  if ::File.exist?("#{node['opennms']['conf']['home']}/etc/#{@current_resource.file}")
    @current_resource.file_exists = true
    if event_file?(@current_resource.file, node)
      @current_resource.is_event_file = true
      if event_in_file?("#{node['opennms']['conf']['home']}/etc/#{@current_resource.file}", @current_resource)
        Chef::Log.debug("uei #{@current_resource.uei} is in file already")
        @current_resource.exists = true
        if event_changed?(@current_resource, node)
          Chef::Log.debug("uei #{@current_resource.uei} has changed.")
          @current_resource.changed = true
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockNesting

private

def create_event_file
  doc = REXML::Document.new
  doc << REXML::XMLDecl.new
  events_el = doc.add_element 'events'
  events_el.add_namespace('http://xmlns.opennms.org/xsd/eventconf')
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
  add_file_to_eventconf(new_resource.file, 'bottom', node)
end

# rubocop:disable Metrics/BlockNesting
def create_event
  uei = new_resource.uei || new_resource.name
  new_resource.uei = uei
  # new_resource.uei = new_resource.name if new_resource.uei.nil?
  # make sure event file is included in main eventconf
  unless event_file_included?(new_resource.file, node)
    add_file_to_eventconf(new_resource.file, 'bottom', node)
  end
  Chef::Log.debug "Adding uei '#{uei}' to '#{new_resource.file}'."

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}", 'r')
  doc = REXML::Document.new file
  file.close
  doc.context[:attribute_quote] = :quote
  updating = false
  event_el = doc.root.elements[event_xpath(new_resource)]
  Chef::Log.debug("Current event_el for #{new_resource}: #{event_el}")
  if event_el.nil?
    if new_resource.position == 'top'
      doc.root.insert_before('/events/event', REXML::Element.new('event'))
      event_el = doc.root.elements['/events/event']
    else
      event_el = doc.root.add_element 'event'
    end
  else
    updating = true
  end
  Chef::Log.debug "Updating #{new_resource}? #{updating}"
  # masks are immutable as they are part of identity.
  if !updating && !new_resource.mask.nil?
    mask_el = event_el.add_element 'mask'
    new_resource.mask.each do |mask|
      mask_container = 'maskelement'
      mask_id = 'mename'
      mask_val = 'mevalue'
      if mask.key?('vbnumber') && mask.key?('vbvalue')
        mask_container = 'varbind'
        mask_id = 'vbnumber'
        mask_val = 'vbvalue'
      end
      me_el = mask_el.add_element mask_container
      name_el = me_el.add_element mask_id
      name_el.add_text mask[mask_id]
      mask[mask_val].each do |value|
        vel = me_el.add_element mask_val
        vel.add_text value
      end
    end
  end
  unless updating
    uei_el = event_el.add_element('uei')
    uei_el.add_text(uei)
  end
  unless new_resource.event_label.nil?
    el_el = event_el.elements['event-label'] || event_el.add_element('event-label')
    el_el.text = nil while el_el.has_text?
    el_el.add_text(REXML::CData.new(new_resource.event_label))
  end
  unless new_resource.snmp.nil?
    # TODO
  end
  unless new_resource.descr.nil?
    descr_el = event_el.elements['descr'] || event_el.add_element('descr')
    descr_el.text = nil while descr_el.has_text?
    descr_el.add_text(REXML::CData.new(new_resource.descr)) unless new_resource.descr.nil?
  end
  if updating
    logmsg_el = event_el.elements['logmsg']
    Chef::Log.debug("new_resource notify is: #{new_resource.logmsg_notify}")
    logmsg_el.attributes['notify'] = 'true' if new_resource.logmsg_notify == true
    logmsg_el.attributes['notify'] = 'false' if new_resource.logmsg_notify == false
    logmsg_el.attributes['dest'] = new_resource.logmsg_dest unless new_resource.logmsg_dest.nil?
    unless new_resource.logmsg.nil?
      logmsg_el.text = nil while logmsg_el.has_text?
      logmsg_el.add_text(REXML::CData.new(new_resource.logmsg)) unless new_resource.logmsg.nil?
    end
  else
    logmsg_el = event_el.add_element 'logmsg'
    logmsg_el.attributes['notify'] = 'true' if new_resource.logmsg_notify == true
    logmsg_el.attributes['dest'] = new_resource.logmsg_dest
    logmsg_el.add_text(REXML::CData.new(new_resource.logmsg))
  end
  unless new_resource.severity.nil?
    sev_el = event_el.elements['severity'] || event_el.add_element('severity')
    sev_el.text = nil while sev_el.has_text?
    sev_el.add_text(new_resource.severity) unless new_resource.severity.nil?
  end
  unless new_resource.correlation.nil?
    # TODO
  end
  unless new_resource.operinstruct.nil?
    event_el.elements.delete('operinstruct') if updating
    oi_el = event_el.add_element 'operinstruct'
    oi_el.add_text(REXML::CData.new(new_resource.operinstruct))
  end
  unless new_resource.autoaction.nil?
    event_el.elements.delete_all('autoaction') if updating
    new_resource.autoaction.each do |autoaction|
      aa_el = event_el.add_element 'autoaction'
      aa_el.attributes['state'] = 'off' if autoaction['state'] == 'off'
      aa_el.add_text(REXML::CData.new(autoaction['action']))
    end
  end
  unless new_resource.varbindsdecode.nil?
    event_el.elements.delete_all('varbindsdecode') if updating
    new_resource.varbindsdecode.each do |vbd|
      vbd_el = event_el.add_element 'varbindsdecode'
      parmid_el = vbd_el.add_element 'parmid'
      parmid_el.add_text(vbd['parmid'])
      vbd['decode'].each do |decode|
        vbd_el.add_element 'decode', 'varbindvalue' => decode['varbindvalue'], 'varbinddecodedstring' => decode['varbinddecodedstring']
      end
    end
  end
  if Opennms::Helpers.major(node['opennms']['version']).to_i > 16
    unless new_resource.parameters.nil?
      event_el.elements.delete_all('parameter') if updating
      new_resource.parameters.each do |param|
        param_el = event_el.add_element 'parameter'
        param_el.add_attribute('name', param['name'])
        param_el.add_attribute('value', param['value'])
        if Opennms::Helpers.major(node['opennms']['version']).to_i > 17 && param.key?('expand')
          param_el.add_attribute('expand', param['expand'])
        end
      end
    end
  end
  unless new_resource.operaction.nil?
    # TODO
  end
  unless new_resource.autoacknowledge.nil?
    # TODO
  end
  unless new_resource.loggroup.nil?
    # TODO
  end
  unless new_resource.tticket.nil?
    event_el.elements.delete('tticket') if updating
    unless new_resource.tticket == false
      tt_el = event_el.add_element 'tticket'
      tt_el.attributes['state'] = 'off' if new_resource.tticket['state'] == 'off'
      tt_el.add_text(REXML::CData.new(new_resource.tticket['info']))
    end
  end
  unless new_resource.forward.nil?
    event_el.elements.delete_all('forward') if updating
    new_resource.forward.each do |forward|
      fw_el = event_el.add_element 'forward'
      fw_el.attributes['state'] = 'off' if forward['state'] == 'off'
      fw_el.attributes['mechanism'] = forward['mechanism'] unless forward['mechanism'].nil?
      fw_el.add_text(REXML::CData.new(forward['info']))
    end
  end
  unless new_resource.script.nil?
    Chef::Log.debug "doing script work because #{new_resource.script}. updating? #{updating}"
    deletes = event_el.elements.delete_all('script') if updating
    Chef::Log.debug "removed #{deletes}"
    new_resource.script.each do |script|
      script_el = event_el.add_element 'script', 'language' => script['language']
      script_el.add_text(script['name'])
    end
  end
  unless new_resource.mouseovertext.nil?
    event_el.elements.delete('mouseovertext') if updating
    mot_el = event_el.add_element 'mouseovertext'
    mot_el.add_text(REXML::CData.new(new_resource.mouseovertext))
  end
  unless new_resource.alarm_data.nil?
    event_el.elements.delete('alarm-data') if updating
    unless new_resource.alarm_data == false
      ad = new_resource.alarm_data
      ad_el = event_el.add_element 'alarm-data', 'reduction-key' => ad['reduction_key'], 'alarm-type' => ad['alarm_type']
      ad_el.attributes['clear-key'] = ad['clear_key'] if ad.key? 'clear_key'
      ad_el.attributes['auto-clean'] = ad['auto_clean'] if ad.key? 'auto_clean'
      ad_el.attributes['x733-alarm-type'] = ad['x733_alarm_type'] if ad.key? 'x733_alarm_type'
      ad_el.attributes['x733-probable-cause'] = ad['x733_probable_cause'] if ad.key? 'x733_probable_cause'
      if ad.key? 'update_fields'
        ad['update_fields'].each do |field|
          uf_el = ad_el.add_element 'update-field', 'field-name' => field['field_name']
          uf_el.attributes['update-on-reduction'] = 'false' if field.key?('update_on_reduction') && field['update_on_reduction'] == false
        end
      end
    end
  end
  Chef::Log.debug("Converged event_el for #{new_resource}: #{event_el}")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
end

def delete_event
  uei = new_resource.uei || new_resource.name
  Chef::Log.debug "Deleting an event with UEI '#{uei}' from '#{new_resource.file}'."

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}", 'r')
  doc = REXML::Document.new file
  file.close
  doc.context[:attribute_quote] = :quote
  doc.root.delete_element(event_xpath(new_resource))
  # determine if that was the last event in the file.
  # If so, delete it (an empty eventconf file isn't valid according to the schema).
  # And remove it from the main eventconf file.
  if doc.root.elements['/events/event'].nil?
    ::File.delete("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
    remove_file_from_eventconf(new_resource.file, node)
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
end
# rubocop:enable Metrics/BlockNesting
