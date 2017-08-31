# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.changed
    converge_by("Create (update) #{@new_resource}") do
      create_notification
    end
  elsif @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_notification
    end
  end
end

action :delete do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} is being deleted."
    converge_by("Delete #{@new_resource}") do
      delete_notification
    end
  else
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsNotification.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.status(@new_resource.status)
  @current_resource.writeable(@new_resource.writeable)
  @current_resource.uei(@new_resource.uei)
  @current_resource.description(@new_resource.description)
  @current_resource.rule(@new_resource.rule)
  @current_resource.destination_path(@new_resource.destination_path)
  @current_resource.text_message(@new_resource.text_message)
  @current_resource.subject(@new_resource.subject)
  @current_resource.numeric_message(@new_resource.numeric_message)
  @current_resource.event_severity(@new_resource.event_severity)
  @current_resource.params(@new_resource.params)
  @current_resource.vbname(@new_resource.vbname)
  @current_resource.vbvalue(@new_resource.vbvalue)

  if notification_exists?(@current_resource.name)
    @current_resource.exists = true
    @current_resource.changed = true if notification_changed?(@current_resource)
  end
end

private

def notification_exists?(name)
  Chef::Log.debug "Checking to see if this notification exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/notifications/notification[@name = '#{name}']"].nil?
end

def notification_changed?(current_resource)
  Chef::Log.debug "Checking to see if this notification has changed: '#{current_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", 'r')
  doc = REXML::Document.new file
  file.close
  notif_el = doc.elements["/notifications/notification[@name = '#{current_resource.name}']"]
  Chef::Log.debug "#{notif_el.attributes['status']} != #{current_resource.status}?"
  return true if notif_el.attributes['status'].to_s != current_resource.status.to_s
  Chef::Log.debug "#{notif_el.attributes['writeable']} != #{current_resource.writeable}?"
  if current_resource.writeable == 'yes'
    # if writeable is not present, it means yes, so only check if
    # writeable is literally equal to 'no'
    return true if notif_el.attributes['writeable'].to_s == 'no'
  elsif notif_el.attributes['writeable'].to_s != 'no'
    # Not changed only if exists and equal to 'no'
    # so return true if it doesn't exist (nil) or is 'yes'
    return true
  end
  ueitext = ''
  # OMG I hate XML text
  notif_el.elements['uei'].texts.each do |t|
    ueitext += t.to_s.strip
  end
  Chef::Log.debug "#{ueitext} != #{REXML::Text.new(current_resource.uei)}?"
  return true if ueitext.to_s != REXML::Text.new(current_resource.uei).to_s
  d_el = notif_el.elements['description']
  if d_el.nil?
    Chef::Log.debug "no existing description, new is #{current_resource.description}"
    return true unless current_resource.description.nil?
  else
    detext = ''
    d_el.texts.each do |t|
      detext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{detext} != #{REXML::Text.new(current_resource.description)}?"
    return true if detext.to_s != REXML::Text.new(current_resource.description).to_s
  end
  rtext = ''
  notif_el.elements['rule'].texts.each do |t|
    rtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
  end
  # we use CData for rules
  Chef::Log.debug "#{rtext} != #{current_resource.rule}?"
  return true if rtext.to_s != current_resource.rule.to_s
  dptext = ''
  notif_el.elements['destinationPath'].texts.each do |t|
    dptext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
  end
  Chef::Log.debug "#{dptext} != #{REXML::Text.new(current_resource.destination_path)}?"
  return true if dptext.to_s != REXML::Text.new(current_resource.destination_path).to_s
  tmtext = ''
  notif_el.elements['text-message'].texts.each do |t|
    tmtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
  end
  # we use CData for text messages
  Chef::Log.debug "#{tmtext} != #{current_resource.text_message}?"
  return true if tmtext.to_s != current_resource.text_message.to_s
  sub_el = notif_el.elements['subject']
  if sub_el.nil?
    Chef::Log.debug "no existing subject, new is #{current_resource.subject}"
    return true unless current_resource.subject.nil?
  else
    stext = ''
    sub_el.texts.each do |t|
      stext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{stext} != #{REXML::Text.new(current_resource.subject)}?"
    return true if stext.to_s != REXML::Text.new(current_resource.subject).to_s
  end
  nm_el = notif_el.elements['numeric-message']
  if nm_el.nil?
    Chef::Log.debug "no existing numeric message, new is #{current_resource.numeric_message}"
    return true unless current_resource.numeric_message.nil?
  else
    nmtext = ''
    nm_el.texts.each do |t|
      nmtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{nmtext} != #{REXML::Text.new(current_resource.numeric_message)}?"
    return true if nmtext.to_s != REXML::Text.new(current_resource.numeric_message).to_s
  end
  es_el = notif_el.elements['event-severity']
  if es_el.nil?
    Chef::Log.debug "no existing event_severity, new is #{current_resource.event_severity}"
    return true unless current_resource.event_severity.nil?
  else
    estext = ''
    es_el.texts.each do |t|
      estext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{estext} != #{REXML::Text.new(current_resource.event_severity)}?"
    return true if estext.to_s != REXML::Text.new(current_resource.event_severity).to_s
  end
  curr_params = {}
  params_str = {}
  current_resource.params.each do |k, v|
    params_str[k.to_s] = v.to_s
  end
  notif_el.elements.each('parameter') do |p|
    curr_params[p.attributes['name'].to_s] = p.attributes['value'].to_s
  end
  Chef::Log.debug "new params: #{current_resource.params}; curr_params: #{curr_params}"
  return true if current_resource.params.nil? && !curr_params.empty?
  return true if !current_resource.params.nil? && !current_resource.params.empty? && curr_params.empty?
  return true if curr_params != params_str
  vn_el = notif_el.elements['varbind/vbname']
  if vn_el.nil?
    Chef::Log.debug "no existing vbname, new is #{current_resource.vbname}"
    return true unless current_resource.vbname.nil?
  else
    vntext = ''
    vn_el.texts.each do |t|
      vntext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{vntext} != #{REXML::Text.new(current_resource.vbname)}?"
    return true if vntext.to_s != REXML::Text.new(current_resource.vbname).to_s
  end
  vv_el = notif_el.elements['varbind/vbvalue']
  if vv_el.nil?
    Chef::Log.debug "no existing vbvalue, new is #{current_resource.vbvalue}"
    return true unless current_resource.vbvalue.nil?
  else
    vvtext = ''
    vv_el.texts.each do |t|
      vvtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
    end
    Chef::Log.debug "#{vvtext} != #{REXML::Text.new(current_resource.vbvalue)}?"
    return true if vvtext.to_s != REXML::Text.new(current_resource.vbvalue).to_s
  end
  false
end

def create_notification
  Chef::Log.debug "Creating notification : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  # handle create and update in one method
  notif_el = doc.elements["/notifications/notification[@name = '#{new_resource.name}']"]
  if notif_el.nil?
    notif_el = doc.root.add_element 'notification', 'name' => new_resource.name, 'status' => new_resource.status
  else
    # if it already exists, remove all children, text and optional attributes
    notif_el.elements.delete_all '*'
    t = notif_el.get_text
    until t.nil?
      notif_el.delete t
      t = notif_el.get_text
    end
    notif_el.attributes.delete 'writeable'
    # set status
    notif_el.attributes['status'] = new_resource.status
  end

  if !new_resource.writeable.nil? && new_resource.writeable != 'yes'
    notif_el.attributes['writeable'] = new_resource.writeable
  end
  uei_el = notif_el.add_element 'uei'
  uei_el.add_text(new_resource.uei)
  unless new_resource.description.nil?
    descr_el = notif_el.add_element 'description'
    descr_el.add_text(new_resource.description)
  end
  rule_el = notif_el.add_element 'rule'
  rule_el.add_text REXML::CData.new(new_resource.rule)
  # if !new_resource.notice_queue.nil?
  #  nq_el = notif_el.add_element 'notice-queue'
  #  nq_el.add_text new_resource.notice_queue
  # end
  dp_el = notif_el.add_element 'destinationPath'
  dp_el.add_text new_resource.destination_path
  tm_el = notif_el.add_element 'text-message'
  tm_el.add_text REXML::CData.new(new_resource.text_message)
  unless new_resource.subject.nil?
    subject_el = notif_el.add_element 'subject'
    subject_el.add_text new_resource.subject
  end
  unless new_resource.numeric_message.nil?
    nm_el = notif_el.add_element 'numeric-message'
    nm_el.add_text new_resource.numeric_message
  end
  unless new_resource.event_severity.nil?
    es_el = notif_el.add_element 'event-severity'
    es_el.add_text new_resource.event_severity
  end
  unless new_resource.params.nil?
    new_resource.params.each do |name, value|
      notif_el.add_element 'parameter', 'name' => name, 'value' => value
    end
  end
  if !new_resource.vbname.nil? && !new_resource.vbvalue.nil?
    varbind_el = notif_el.add_element 'varbind'
    vbname_el = varbind_el.add_element 'vbname'
    vbname_el.add_text new_resource.vbname
    vbvalue_el = varbind_el.add_element 'vbvalue'
    vbvalue_el.add_text new_resource.vbvalue
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/notifications.xml")
end

def delete_notification
  Chef::Log.debug "Creating notification : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close
  # we've already established that the current resource is what we described to delete
  doc.elements.delete("/notifications/notification[@name = '#{new_resource.name}']")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/notifications.xml")
end
