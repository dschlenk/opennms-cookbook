def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Wallboard specified '#{@current_resource.wallboard}' doesn't exist!") unless @current_resource.wallboard_exists
  if @current_resource.changed
    converge_by("Update #{ @new_resource }") do
      update_dashlet
      new_resource.updated_by_last_action(true)
    end
  elsif @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_dashlet
      new_resource.updated_by_last_action(true)
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
      if dashlet_changed?(@current_resource.wallboard,
                            @current_resource.title,
                            @current_resource.boost_duration,
                            @current_resource.boost_priority,
                            @current_resource.duration,
                            @current_resource.priority,
                            @current_resource.dashlet_name,
                            @current_resource.parameters)
        @current_resource.changed = true
      end
    end
  end
end

private 

def wallboard_exists?(title)
  return false unless ::File.exist? "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "r")
  doc = REXML::Document.new file
  file.close
  !doc.elements["/wallboards/wallboard[@title = '#{title}']"].nil?
end

def dashlet_exists?(wallboard, title)
  return false unless ::File.exist? "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "r")
  doc = REXML::Document.new file
  file.close
  !doc.elements["/wallboards/wallboard[@title = '#{wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{title}')]]]"].nil?
end

def dashlet_changed?(wallboard, title, boost_duration, boost_priority,
                     duration, priority, dashlet_name, parameters)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "r")
  doc = REXML::Document.new file
  file.close
  dashlet = doc.elements["/wallboards/wallboard[@title = '#{wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{title}')]]]"]
  curr_bd = dashlet.elements["boostDuration"].text.strip
  Chef::Log.info "#{curr_bd} != #{boost_duration}?"
  return true if "#{curr_bd}" != "#{boost_duration}"
  curr_bp = dashlet.elements["boostPriority"].text.strip
  Chef::Log.info "#{curr_bp} != #{boost_priority}?"
  return true if "#{curr_bp}" != "#{boost_priority}"
  curr_duration = dashlet.elements["duration"].text.strip
  Chef::Log.info "#{curr_duration} != #{duration}?"
  return true if "#{curr_duration}" != "#{duration}"
  curr_priority = dashlet.elements["priority"].text.strip
  Chef::Log.info "#{curr_priority} != #{priority}?"
  return true if "#{curr_priority}" != "#{priority}"
  curr_dn = dashlet.elements['dashletName'].text.strip
  Chef::Log.info "#{curr_dn} != #{dashlet_name}?"
  return true if "#{curr_dn}" != "#{dashlet_name}"
  curr_parameters = {}
  dashlet.elements["parameters"].elements.each 'entry' do |entry|
    key = entry.elements["key"].text.strip
    # it's valid to have no text for the value
    value = entry.elements["value"].text
    value.strip! unless value.nil?
    curr_parameters[key] = value
  end
  Chef::Log.info "#{curr_parameters} != #{parameters}?"
  return true if curr_parameters != parameters
  return false
end

def create_dashlet
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "r")
  doc = REXML::Document.new file
  file.close
  wb = doc.elements["/wallboards/wallboard[@title = '#{new_resource.wallboard}']"]
  dashlets = wb.elements["dashlets"]
  dashlets ||= wb.add_element 'dashlets'

  dashlet = dashlets.add_element 'dashlet'
  bd = dashlet.add_element 'boostDuration'
  bd.text = "#{new_resource.boost_duration}"
  bp = dashlet.add_element 'boostPriority'
  bp.text = "#{new_resource.boost_duration}"
  dn = dashlet.add_element 'dashletName'
  dn.text = new_resource.dashlet_name
  d = dashlet.add_element 'duration'
  d.text = "#{new_resource.duration}"
  p = dashlet.add_element 'parameters'
  new_resource.parameters.each do |k,v|
    entry = p.add_element 'entry'
    key = entry.add_element 'key'
    key.text = k
    value = entry.add_element 'value'
    value.text = v
  end
  pri = dashlet.add_element 'priority'
  pri.text = "#{new_resource.priority}"
  title = dashlet.add_element 'title'
  title.text = new_resource.title
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "w"){ |file| file.puts(out) } 
end

def update_dashlet
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "r")
  doc = REXML::Document.new file
  file.close
  dashlet = doc.elements["/wallboards/wallboard[@title = '#{new_resource.wallboard}']/dashlets/dashlet[title[text()[contains(.,'#{new_resource.title}')]]]"]
  bd = dashlet.elements['boostDuration']
  bd.text = "#{new_resource.boost_duration}"
  bp = dashlet.elements['boostPriority']
  bp.text = "#{new_resource.boost_duration}"
  dn = dashlet.elements['dashletName']
  dn.text = new_resource.dashlet_name
  d = dashlet.elements['duration']
  d.text = "#{new_resource.duration}"
  dashlet.delete_element 'parameters'
  p = dashlet.add_element 'parameters'
  new_resource.parameters.each do |k,v|
    entry = p.add_element 'entry'
    key = entry.add_element 'key'
    key.text = k
    value = entry.add_element 'value'
    value.text = v
  end
  pri = dashlet.elements['priority']
  pri.text = "#{new_resource.priority}"
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", "w"){ |file| file.puts(out) } 
end
