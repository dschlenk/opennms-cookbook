# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_autoack
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsNotifdAutoack.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.acknowledge(@new_resource.acknowledge)

  if autoack_exists?(@current_resource.name, @current_resource.acknowledge)
    @current_resource.exists = true
  end
end

private

def autoack_exists?(name, ack)
  Chef::Log.debug "Checking to see if this autoack exists: '#{name}' for '#{ack}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/notifd-configuration/auto-acknowledge[@uei = '#{name}' and @acknowledge = '#{ack}']"].nil?
end

def create_autoack
  Chef::Log.debug "Creating autoack : '#{new_resource.name}' for '#{new_resource.acknowledge}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  last_autoack_el = doc.root.elements['/notifd-configuration/auto-acknowledge[last()]']
  autoack_el = REXML::Element.new 'auto-acknowledge'
  autoack_el.attributes['uei'] = new_resource.name
  autoack_el.attributes['acknowledge'] = new_resource.acknowledge
  if !new_resource.resolution_prefix.nil? && new_resource.resolution_prefix != 'RESOLVED: '
    autoack_el.attributes['resolution-prefix'] = new_resource.resolution_prefix
  end
  if !new_resource.notify.nil? && new_resource.notify.to_s != 'true'
    autoack_el.attributes['notify'] = 'false'
  end
  new_resource.matches.each do |match|
    match_el = autoack_el.add_element 'match'
    match_el.add_text match
  end
  if last_autoack_el.nil?
    first_queue_el = doc.root.elements['/notifd-configuration/queue[1]']
    doc.root.insert_before(first_queue_el, autoack_el)
  else
    doc.root.insert_after(last_autoack_el, autoack_el)
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/notifd-configuration.xml")
end
