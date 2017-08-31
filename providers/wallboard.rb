# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.changed
    converge_by("Update #{@new_resource}") do
      update_wallboard
    end
  elsif @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_wallboard
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsWallboard.new(@new_resource.name)
  @current_resource.title(@new_resource.title)
  @current_resource.set_default(@new_resource.set_default)

  if wallboard_exists?(@current_resource.title)
    @current_resource.exists = true
    if wallboard_changed?(@current_resource.title, @current_resource.set_default)
      @current_resource.changed = true
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

def wallboard_changed?(title, set_default)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  current_default = doc.elements["/wallboards/wallboard[@title = '#{title}']/default"].text.strip
  current_default.to_s != set_default.to_s
end

def create_wallboard
  doc = nil
  if ::File.exist? "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
    doc = REXML::Document.new file
    file.close
  else
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new
    doc.add_element 'wallboards'
  end
  wbs = doc.elements['/wallboards']
  wb = wbs.add_element 'wallboard', 'title' => new_resource.title
  if new_resource.set_default == true
    wbs.elements.each 'wallboard' do |w|
      if !w.elements['default'].nil? && w.elements['default'].text.strip == 'true'
        w.elements['default'].text = 'false'
      end
    end
  end
  wbd = wb.add_element 'default'
  wbd.add_text new_resource.set_default.to_s
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml")
end

def update_wallboard
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/dashboard-config.xml", 'r')
  doc = REXML::Document.new file
  file.close
  wbs = doc.elements['/wallboards']
  if new_resource.set_default == true
    # find previous default if exists and change it to false
    wbs.elements.each 'wallboard' do |w|
      if w.elements['default'].text.strip == 'true'
        w.elements['default'].text = 'false'
      end
    end
  end
  wb = wbs.elements["wallboard[@title = '#{new_resource.title}']"]
  wb.elements['default'].text = new_resource.set_default.to_s
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/dashboard-config.xml")
end
