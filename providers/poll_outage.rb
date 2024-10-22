# frozen_string_literal: true

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    @new_resource.times.each do |_k, v|
      Chef::Log.fatal "Poll outage times require a value for 'begins'." unless v.key?('begins')
      Chef::Log.fatal "Poll outage times require a value for 'ends'." unless v.key?('ends')
    end
    converge_by("Create #{@new_resource}") do
      create_poll_outage
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Delete #{@new_resource}") do
      delete_poll_outage
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_poll_outage, node).new(@new_resource.outage_name || @new_resource.name)
  @current_resource.exists = true if poll_outage_exists?(@new_resource.outage_name || @new_resource.name)
end

private

def poll_outage_exists?(name)
  Chef::Log.debug "Checking to see if this poll outage exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poll-outages.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/outages/outage[@name='#{name}']"].nil?
end

def create_poll_outage
  name = new_resource.outage_name || new_resource.name
  Chef::Log.debug "Adding poll outage: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poll-outages.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  outages = doc.elements['/outages']
  oe = outages.add_element('outage')
  oe.add_attribute('name', name)
  oe.add_attribute('type', new_resource.type)
  new_resource.times.each do |k, v|
    te = oe.add_element('time')
    te.add_attribute('id', k)
    te.add_attribute('day', v['day']) unless v['day'].nil?
    te.add_attribute('begins', v['begins'])
    te.add_attribute('ends', v['ends'])
  end
  new_resource.interfaces.each do |i|
    ie = oe.add_element('interface')
    ie.add_attribute('address', i)
  end
  new_resource.nodes.each do |n|
    ne = oe.add_element('node')
    ne.add_attribute('id', n)
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poll-outages.xml")
end

def delete_poll_outage
  name = new_resource.outage_name || new_resource.name
  Chef::Log.debug "Adding poll outage: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/poll-outages.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  doc.delete_element("/outages/outage[@name = '#{name}']")
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/poll-outages.xml")
end
