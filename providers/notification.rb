def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.changed
    converge_by("Create (update) #{ @new_resource }") do
      create_notification
      new_resource.updated_by_last_action(true)
    end
  elsif @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_notification
      new_resource.updated_by_last_action(true)
    end
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
    if notification_changed?(@current_resource.name, @current_resource.status,
                            @current_resource.writeable, @current_resource.uei,
                            @current_resource.description,
                            @current_resource.rule,
                            @current_resource.destination_path,
                            @current_resource.text_message,
                            @current_resource.subject,
                            @current_resource.numeric_message,
                            @current_resource.event_severity,
                            @current_resource.params,
                            @current_resource.vbname, @current_resource.vbvalue)
      @current_resource.changed = true
    end
  end
end

private

def notification_exists?(name)
  Chef::Log.debug "Checking to see if this notification exists: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", "r")
  doc = REXML::Document.new file
  file.close
  !doc.elements["/notifications/notification[@name = '#{name}']"].nil?
end

def notification_changed?(name, status, writeable, uei, description, rule,
                          destination_path, text_message, subject,
                          numeric_message, event_severity, params, vbname,
                          vbvalue)
  Chef::Log.debug "Checking to see if this notification has changed: '#{ name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", "r")
  doc = REXML::Document.new file
  file.close
  notif_el = doc.elements["/notifications/notification[@name = '#{name}']"]
  Chef::Log.debug "#{notif_el.attributes['status']} != #{status}?"
  return true if "#{notif_el.attributes['status']}" != "#{status}"
  Chef::Log.debug "#{notif_el.attributes['writeable']} != #{writeable}?"
  if writeable == 'yes'
    # if writeable is not present, it means yes, so only check if 
    # writeable is literally equal to 'no'
    return true if "#{notif_el.attributes['writeable']}" == 'no'
  else
    # Not changed only if exists and equal to 'no'
    # so return true if it doesn't exist (nil) or is 'yes'
    return true if "#{notif_el.attributes['writeable']}" != 'no'
  end
  Chef::Log.debug "#{notif_el.elements['uei'].texts.join("\n").strip} != #{uei}?"
  return true if "#{notif_el.elements['uei'].texts.join("\n").strip}" != "#{uei}"
  d_el = notif_el.elements['description']
  if d_el.nil?
    Chef::Log.debug "no existing description, new is #{description}"
    return true unless description.nil?
  else
    Chef::Log.debug "#{d_el.texts.join("\n").strip} != #{description}?"
    return true if "#{d_el.texts.join("\n").strip}" != "#{description}"
  end
  Chef::Log.debug "#{notif_el.elements['rule'].texts.join("\n").strip} != #{rule}?"
  return true if "#{notif_el.elements['rule'].texts.join("\n").strip}" != "#{rule}"
  Chef::Log.debug "#{notif_el.elements['destinationPath'].texts.join("\n").strip} != #{destination_path}?"
  return true if "#{notif_el.elements['destinationPath'].texts.join("\n").strip}" != "#{destination_path}"
  Chef::Log.debug "#{notif_el.elements['text-message'].texts.join("\n").strip} != #{text_message}?"
  return true if "#{notif_el.elements['text-message'].texts.join("\n").strip}" != "#{text_message}"
  sub_el = notif_el.elements['subject']
  if sub_el.nil?
    Chef::Log.debug "no existing subject, new is #{subject}"
    return true unless subject.nil?
  else
    Chef::Log.debug "#{sub_el.texts.join("\n").strip} != #{subject}?"
    return true if "#{sub_el.texts.join("\n").strip}" != "#{subject}"
  end
  nm_el = notif_el.elements['numeric-message']
  if nm_el.nil?
    Chef::Log.debug "no existing numeric message, new is #{numeric_message}"
    return true unless numeric_message.nil?
  else
    Chef::Log.debug "#{nm_el.texts.join("\n").strip} != #{numeric_message}?"
    return true if "#{nm_el.texts.join("\n").strip}" != "#{numeric_message}"
  end
  es_el = notif_el.elements['event-severity']
  if es_el.nil?
    Chef::Log.debug "no existing event_severity, new is #{event_severity}"
    return true unless event_severity.nil?
  else
    Chef::Log.debug "#{es_el.texts.join("\n").strip} != #{event_severity}?"
    return true if "#{es_el.texts.join("\n").strip}" != "#{event_severity}"
  end
  curr_params = {}
  params_str = {}
  params.each do |k,v|
    params_str["#{k}"] = "#{v}" 
  end
  params_el = notif_el.elements.each('parameter') do |p|
    curr_params["#{p.attributes['name']}"] = "#{p.attributes['value']}"
  end
  Chef::Log.debug "new params: #{params}; curr_params: #{curr_params}"
  return true if params.nil? && curr_params.size > 0
  return true if !params.nil? && params.size > 0 && curr_params.size == 0
  return true if curr_params != params_str
  vn_el = notif_el.elements['varbind/vbname']
  if vn_el.nil?
    Chef::Log.debug "no existing vbname, new is #{vbname}"
    return true unless vbname.nil?
  else
    Chef::Log.debug "#{vn_el.texts.join("\n").strip} != #{vbname}?"
    return true if "#{vn_el.texts.join("\n").strip}" != "#{vbname}"
  end
  vv_el = notif_el.elements['varbind/vbvalue']
  if vv_el.nil?
    Chef::Log.debug "no existing vbvalue, new is #{vbvalue}"
    return true unless vbvalue.nil?
  else
    Chef::Log.debug "#{vv_el.texts.join("\n").strip} != #{vbvalue}?"
    return true if "#{vv_el.texts.join("\n").strip}" != "#{vbvalue}"
  end
  return false
end

def create_notification
  Chef::Log.debug "Creating notification : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  # handle create and update in one method
  notif_el = doc.elements["/notifications/notification[@name = '#{new_resource.name}']"]
  if notif_el.nil?
    notif_el = doc.root.add_element 'notification', { 'name' => new_resource.name, 'status' => new_resource.status }
  else
    # if it already exists, remove all children, text and optional attributes
    notif_el.elements.delete_all '*'
    while t = notif_el.get_text
      notif_el.delete t
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
  if !new_resource.description.nil?
    descr_el = notif_el.add_element 'description'
    descr_el.add_text(new_resource.description)
  end
  rule_el = notif_el.add_element 'rule'
  rule_el.add_text REXML::CData.new(new_resource.rule)
  #if !new_resource.notice_queue.nil?
  #  nq_el = notif_el.add_element 'notice-queue'
  #  nq_el.add_text new_resource.notice_queue
  #end
  dp_el = notif_el.add_element 'destinationPath'
  dp_el.add_text new_resource.destination_path
  tm_el = notif_el.add_element 'text-message'
  tm_el.add_text REXML::CData.new(new_resource.text_message)
  if !new_resource.subject.nil?
    subject_el = notif_el.add_element 'subject'
    subject_el.add_text new_resource.subject
  end
  if !new_resource.numeric_message.nil?
    nm_el = notif_el.add_element 'numeric-message'
    nm_el.add_text new_resource.numeric_message
  end
  if !new_resource.event_severity.nil?
    es_el = notif_el.add_element 'event-severity'
    es_el.add_text new_resource.event_severity
  end
  if !new_resource.params.nil?
    new_resource.params.each do |name, value|
      notif_el.add_element 'parameter', {'name' => name, 'value' => value}
    end
  end
  if !new_resource.vbname.nil? && !new_resource.vbvalue.nil?
    varbind_el = notif_el.add_element 'varbind'
    vbname_el = varbind_el.add_element 'vbname'
    vbname_el.add_text new_resource.vbname
    vbvalue_el = varbind_el.add_element 'vbvalue'
    vbvalue_el.add_text new_resource.vbvalue
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/notifications.xml", "w"){ |file| file.puts(out) }
end
