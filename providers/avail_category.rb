def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("CategoryGroup specified '#{@current_resource.category_group}' doesn't exist!") unless @current_resource.catgroup_exists
  if @current_resource.changed
    Chef::Log.info "#{ @new_resource } already exists but has changed - updating."
    converge_by("Update #{ @new_resource }") do
      update_avail_category
      new_resource.updated_by_last_action(true)
    end
  elsif @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_avail_category
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsAvailCategory.new(@new_resource.name)
  @current_resource.label(@new_resource.name)
  @current_resource.category_group(@new_resource.category_group)
  @current_resource.comment(@new_resource.comment)
  @current_resource.normal(@new_resource.normal)
  @current_resource.warning(@new_resource.warning)
  @current_resource.rule(@new_resource.rule)
  @current_resource.services(@new_resource.services)

  if category_group_exists?(@current_resource.category_group)
    @current_resource.catgroup_exists = true
    if category_exists?(@current_resource.category_group, @current_resource.label)
      @current_resource.exists = true
      if category_changed?(@current_resource.label, 
                           @current_resource.category_group,
                           @current_resource.comment,
                           @current_resource.normal,
                           @current_resource.warning, 
                           @current_resource.rule,
                           @current_resource.services)
        @current_resource.changed = true
      end
    end
  end
end

def category_group_exists?(group)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", "r")
  doc = REXML::Document.new file
  file.close
  Chef::Log.debug "group is #{group}"
  name_el = doc.elements["/catinfo/categorygroup/name[text()[contains(.,'#{group}')]]"]
  Chef::Log.debug "#{name_el}"
  !name_el.nil?
end

def category_exists?(group, label)
  Chef::Log.debug "label: #{label}"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", "r")
  doc = REXML::Document.new file
  file.close
  !doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{group}')]]]/categories/category/label[text()[contains(.,'#{label}')]]"].nil?
end

def category_changed?(label, category_group, comment, normal, warning, rule, services)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", "r")
  doc = REXML::Document.new file
  file.close
  cat_el = doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{category_group}')]]]/categories/category[label[text()[contains(.,'#{label}')]]]"]
  label_el = cat_el.elements["label"]
  comment_el = cat_el.elements["comment"]
  normal_el = cat_el.elements["normal"]
  warn_el = cat_el.elements["warning"]
  rule_el = cat_el.elements["rule"]
  return true if "#{label_el.text}" != "#{label}"
  Chef::Log.debug("#{label_el.text} == #{label}")
  return true if "#{comment_el.text}" !=  "#{comment}"
  Chef::Log.debug("#{comment_el.text} ==  #{comment}")
  return true if "#{normal_el.text}" != "#{normal}"
  Chef::Log.debug("#{normal_el.text} == #{normal}")
  return true if "#{warn_el.text}" != "#{warning}"
  Chef::Log.debug("#{warn_el.text} == #{warning}")
  curr_services = []
  cat_el.elements.each "service" do |s|
    curr_services.push "#{s.text}"
  end
  curr_services.sort!
  services.sort!
  return true if curr_services != services
  Chef::Log.debug("#{curr_services} == #{services}")
  #return true if "#{service_els.text}" != "#{rule}"
  return true if "#{rule_el.text}" != "#{rule}"
  Chef::Log.debug("#{rule_el.text} == #{rule}")
  return false
end

def update_avail_category
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", "r")
  doc = REXML::Document.new file
  file.close
  cat_el = doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{new_resource.category_group}')]]]/categories/category[label[text()[contains(.,'#{new_resource.label}')]]]"]
  comment_el = cat_el.elements["comment"]
  # clear out existing text
  while comment_el.has_text?
    comment_el.text = nil
  end
  comment_el.add_text new_resource.comment
  normal_el = cat_el.elements['normal']
  while normal_el.has_text?
    normal_el.text = nil
  end
  normal_el.add_text new_resource.normal.to_s
  warning_el = cat_el.elements['warning']
  while warning_el.has_text?
    warning_el.text = nil
  end
  warning_el.add_text new_resource.warning.to_s
  cat_el.elements.delete_all 'service'
  new_resource.services.each do |s|
    s_el = cat_el.add_element 'service'
    s_el.add_text s
  end
  rule_el = cat_el.elements['rule']
  while rule_el.has_text?
    rule_el.text = nil
  end
  rule_el.add_text(REXML::CData.new(new_resource.rule))
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/categories.xml", "w"){ |file| file.puts(out) }
end

# order doesn't matter here - these just exist to be referenced by viewdisplay.xml
def create_avail_category
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/categories.xml", "r")
  doc = REXML::Document.new file
  file.close
  cg_el = doc.elements["/catinfo/categorygroup[name[text()[contains(.,'#{new_resource.category_group}')]]]/categories"]
  cat_el = cg_el.add_element 'category'
  label_el = cat_el.add_element 'label'
  label_el.add_text(REXML::CData.new(new_resource.label))
  comment_el = cat_el.add_element 'comment'
  comment_el.add_text new_resource.comment
  normal_el = cat_el.add_element 'normal'
  normal_el.add_text "#{new_resource.normal}" # really ruby? really?
  warning_el = cat_el.add_element 'warning'
  warning_el.add_text "#{new_resource.warning}"
  new_resource.services.each do |s|
    s_el = cat_el.add_element 'service'
    s_el.add_text s
  end
  rule_el = cat_el.add_element 'rule'
  rule_el.add_text(REXML::CData.new(new_resource.rule))
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/categories.xml", "w"){ |file| file.puts(out) }
end
