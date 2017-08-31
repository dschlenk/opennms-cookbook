# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("view_name specified '#{@current_resource.view_name}' doesn't exist!") unless @current_resource.view_name_exists
  Chef::Application.fatal!("Some categories specified in '#{@current_resource}' don't exist!") unless @current_resource.categories_exist
  Chef::Application.fatal!("position requested in '#{@current_resource}' is invalid!") unless @current_resource.position_valid
  if @current_resource.changed
    Chef::Log.info "#{@new_resource} already exists but has changed - updating."
    converge_by("Update #{@new_resource}") do
      update_avail_view_section
    end
  elsif @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_avail_view_section
    end
  end
end

# rubocop:disable Metrics/BlockNesting
def load_current_resource
  @current_resource = Chef::Resource::OpennmsAvailViewSection.new(@new_resource.name)
  @current_resource.section(@new_resource.section)
  @current_resource.view_name(@new_resource.view_name)
  @current_resource.category_group(@new_resource.category_group)
  @current_resource.categories(@new_resource.categories)

  if position_valid?(@current_resource.view_name,
                     @current_resource.before,
                     @current_resource.after)
    @current_resource.position_valid = true
  end
  if view_name_exists?(@current_resource.view_name)
    @current_resource.view_name_exists = true
    if categories_exist?(@current_resource.category_group, @current_resource.categories)
      @current_resource.categories_exist = true
      if view_section_exists?(@current_resource.view_name, @current_resource.section)
        @current_resource.exists = true
        if view_section_changed?(@current_resource.view_name,
                                 @current_resource.section,
                                 @current_resource.categories)
          @current_resource.changed = true
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockNesting

def categories_exist?(group, categories)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", 'r')
  doc = REXML::Document.new file
  file.close
  return false if doc.elements["/catinfo/categorygroup/name[text()[contains(.,'#{group}')]]"].nil?
  categories.each do |c|
    return false if doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{group}')]]]/categories/category/label[text() = '#{c}']"].nil?
  end
  true
end

def view_name_exists?(view_name)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/viewinfo/view/view-name[text()[contains(.,'#{view_name}')]]"].nil?
end

def view_section_exists?(view_name, section)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/viewinfo/view[view-name[text()[contains(.,'#{view_name}')]]]/section/section-name[text() = '#{section}']"].nil?
end

def view_section_changed?(view_name, section, categories)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  section_el = doc.elements["/viewinfo/view[view-name[text()[contains(.,'#{view_name}')]]]/section[section-name[text() = '#{section}']]"]
  curr_cats = []
  section_el.elements.each 'category' do |c|
    curr_cats.push c.text.to_s
  end
  # even just order changing is a change so we can use array equality without sorting first
  return true if curr_cats != categories
  Chef::Log.debug("#{curr_cats} == #{categories}")
  false
end

def position_valid?(view_name, before, after)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  view_el = doc.elements["/viewinfo/view[view-name[text()[contains(.,'#{view_name}')]]]"]
  if !before.nil?
    Chef::Log.debug "before is defined as #{before}"
    return !view_el.elements["section[section-name[text()[contains(.,'#{before}')]]]"].nil?
  elsif !after.nil?
    Chef::Log.debug "after is defined as #{after}"
    return !view_el.elements["section[section-name[text()[contains(.,'#{after}')]]]"].nil?
  else
    Chef::Log.debug 'falling back to position'
    return true
  end
end

def update_avail_view_section
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  section_el = doc.elements["/viewinfo/view[view-name[text()[contains(.,'#{new_resource.view_name}')]]]/section[section-name[text() = '#{new_resource.section}']]"]
  section_el.elements.delete_all 'category'
  new_resource.categories.each do |c|
    c_el = section_el.add_element 'category'
    c_el.add_text(REXML::CData.new(c))
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml")
end

def create_avail_view_section
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml", 'r')
  doc = REXML::Document.new file
  file.close
  view_el = doc.elements["/viewinfo/view[view-name[text()[contains(.,'#{new_resource.view_name}')]]]"]
  section_el = REXML::Element.new 'section'
  if !new_resource.before.nil?
    target_el = view_el.elements["section[section-name[text() = '#{new_resource.before}']]"]
    view_el.insert_before target_el, section_el
  elsif !new_resource.after.nil?
    target_el = view_el.elements["section[section-name[text() = '#{new_resource.after}']]"]
    view_el.insert_after target_el, section_el
  elsif new_resource.position == 'bottom'
    view_el.add_element section_el
  else
    fvs_el = view_el.elements['section']
    view_el.insert_before fvs_el, section_el
  end
  sn_el = section_el.add_element 'section-name'
  sn_el.add_text(REXML::CData.new(new_resource.section))
  new_resource.categories.each do |c|
    c_el = section_el.add_element 'category'
    c_el.add_text(REXML::CData.new(c))
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/viewsdisplay.xml")
end
