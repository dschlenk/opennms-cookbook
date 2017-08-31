# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Wallboard specified '#{@current_resource.wallboard}' doesn't exist!") unless @current_resource.wallboard_exists
  if @current_resource.changed
    converge_by("Update #{@new_resource}") do
      update_dashlet
    end
  elsif @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_dashlet
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsDashlet.new(@new_resource.name)
  @current_resource.title(@new_resource.title)
  @current_resource.wallboard(@new_resource.wallboard)
  @current_resource.boost_duration(@new_resource.boost_duration)
  @current_resource.boost_priority(@new_resource.boost_priority)
  @current_resource.duration(@new_resource.duration)
  @current_resource.priority(@new_resource.priority)
  @current_resource.dashlet_name(@new_resource.dashlet_name)
  @current_resource.parameters(@new_resource.parameters)

  if wallboard_exists?(@current_resource.wallboard)
    @current_resource.wallboard_exists = true
    if dashlet_exists?(@current_resource.wallboard, @current_resource.title)
      @current_resource.exists = true
      @current_resource.changed = true if dashlet_changed?(@current_resource)
    end
  end
end

private

def wallboard_exists?(title)
  return false unless ::File.exist? "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/wallboards/wallboard[@title = '#{title}']"].nil?
end

def dashlet_exists?(wallboard, title)
  return false unless ::File.exist? "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/wallboards/wallboard[@title = '#{wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{title}')]]]"].nil?
end

def dashlet_changed?(current_resource)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  dashlet = doc.elements["/wallboards/wallboard[@title = '#{current_resource.wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{current_resource.title}')]]]"]
  curr_bd = dashlet.elements['boostDuration'].text.strip
  Chef::Log.debug "#{curr_bd} != #{current_resource.boost_duration}?"
  return true if curr_bd.to_s != current_resource.boost_duration.to_s
  curr_bp = dashlet.elements['boostPriority'].text.strip
  Chef::Log.debug "#{curr_bp} != #{current_resource.boost_priority}?"
  return true if curr_bp.to_s != current_resource.boost_priority.to_s
  curr_duration = dashlet.elements['duration'].text.strip
  Chef::Log.debug "#{curr_duration} != #{current_resource.duration}?"
  return true if curr_duration.to_s != current_resource.duration.to_s
  curr_priority = dashlet.elements['priority'].text.strip
  Chef::Log.debug "#{curr_priority} != #{current_resource.priority}?"
  return true if curr_priority.to_s != current_resource.priority.to_s
  curr_dn = dashlet.elements['dashletName'].text.strip
  Chef::Log.debug "#{curr_dn} != #{current_resource.dashlet_name}?"
  return true if curr_dn.to_s != current_resource.dashlet_name.to_s
  curr_parameters = {}
  dashlet.elements['parameters'].elements.each 'entry' do |entry|
    key = entry.elements['key'].text.strip
    # it's valid to have no text for the value
    value = entry.elements['value'].text
    value.strip! unless value.nil?
    value = '' if value.nil?
    curr_parameters[key] = value
  end
  Chef::Log.debug "#{curr_parameters} != #{current_resource.parameters}?"
  return true if curr_parameters != current_resource.parameters
  false
end

def create_dashlet
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  wb = doc.elements["/wallboards/wallboard[@title = '#{new_resource.wallboard}']"]
  dashlets = wb.elements['dashlets']
  dashlets ||= wb.add_element 'dashlets'

  dashlet = dashlets.add_element 'dashlet'
  bd = dashlet.add_element 'boostDuration'
  bd.text = new_resource.boost_duration.to_s
  bp = dashlet.add_element 'boostPriority'
  bp.text = new_resource.boost_duration.to_s
  dn = dashlet.add_element 'dashletName'
  dn.text = new_resource.dashlet_name
  d = dashlet.add_element 'duration'
  d.text = new_resource.duration.to_s
  p = dashlet.add_element 'parameters'
  new_resource.parameters.each do |k, v|
    entry = p.add_element 'entry'
    key = entry.add_element 'key'
    key.text = k
    value = entry.add_element 'value'
    value.text = v
  end
  pri = dashlet.add_element 'priority'
  pri.text = new_resource.priority.to_s
  title = dashlet.add_element 'title'
  title.text = new_resource.title
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml")
end

def update_dashlet
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  dashlet = doc.elements["/wallboards/wallboard[@title = '#{new_resource.wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{new_resource.title}')]]]"]
  bd = dashlet.elements['boostDuration']
  bd.text = new_resource.boost_duration.to_s
  bp = dashlet.elements['boostPriority']
  bp.text = new_resource.boost_duration.to_s
  dn = dashlet.elements['dashletName']
  dn.text = new_resource.dashlet_name
  d = dashlet.elements['duration']
  d.text = new_resource.duration.to_s
  dashlet.delete_element 'parameters'
  p = dashlet.add_element 'parameters'
  new_resource.parameters.each do |k, v|
    entry = p.add_element 'entry'
    key = entry.add_element 'key'
    key.text = k
    value = entry.add_element 'value'
    value.text = v
  end
  pri = dashlet.elements['priority']
  pri.text = new_resource.priority.to_s
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml")
end
