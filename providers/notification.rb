def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
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

  if notification_exists?(@current_resource.name)
    @current_resource.exists = true
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

def create_notification
  Chef::Log.debug "Creating notification : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifications.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  notif_el = doc.root.add_element 'notification', { 'name' => new_resource.name, 'status' => new_resource.status }
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
  tm_el.add_text new_resource.text_message
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
