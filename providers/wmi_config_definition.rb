def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - does it need updating?."
    if @current_resource.different
      converge_by("Update #{@new_resource}") do
        update_wmi_config_definition
        new_resource.updated_by_last_action(true)
      end
    else
        Chef::Log.info "#{@new_resource} hasn't changed - nothing to do."
    end
  else
    converge_by("Create #{ @new_resource }") do
      create_wmi_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_wmi_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{ @new_resource } doesn't exist - nothing to do."
  else
    converge_by("Delete #{ @new_resource }") do
      delete_wmi_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsWmiConfigDefinition.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.retry_count(@new_resource.retry_count)
  @current_resource.timeout(@new_resource.timeout)
  @current_resource.username(@new_resource.username)
  @current_resource.domain(@new_resource.domain)
  @current_resource.password(@new_resource.password)

  @current_resource.ranges(@new_resource.ranges)
  @current_resource.specifics(@new_resource.specifics)
  @current_resource.ip_matches(@new_resource.ip_matches)

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "r")
  contents = file.read
  file.close

  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  def_el = matching_def(doc, @current_resource.retry_count,
                        @current_resource.timeout, 
                        @current_resource.username, 
                        @current_resource.domain, 
                        @current_resource.password)
   if !def_el.nil?
     @current_resource.exists = true
     if ranges_equal?(def_el, @current_resource.ranges)\
     && specifics_equal?(def_el, @current_resource.specifics)\
     && ip_matches_equal?(def_el, @current_resource.ip_matches)
       @current_resource.different = false
     else
       @current_resource.different = true
     end
  else
     @current_resource.different = true
  end
end


private

def matching_def(doc, retry_count, timeout, username, domain, password)

  definition = nil
  doc.elements.each("/wmi-config/definition") do |def_el|
    if "#{def_el.attributes['retry']}" == "#{retry_count}"\
    && "#{def_el.attributes['timeout']}" == "#{timeout}"\
    && "#{def_el.attributes['username']}" == "#{username}"\
    && "#{def_el.attributes['domain']}" == "#{domain}"\
    && "#{def_el.attributes['password']}"== "#{password}"
      definition =  def_el
      break
    end
  end
  definition
end

def ranges_equal?(def_el, ranges)
  equal = true # optimistic
  found = false
  if !ranges.nil?
    ranges.each do |r_begin, r_end|
      def_el.elements.each("range") do |range|
        if range.attributes['begin'] == r_begin && range.attributes['end'] == r_end
          found = true
          break
        end
      end
      break if found
    end
  end
  equal = false if !found

  if equal
    found = false
    def_el.elements.each("range") do |range|
      if !ranges.nil?
        ranges.each do |r_begin, r_end|
          if r_begin == range.attributes['begin'] && r_end == range.attributes['end']
            found = true
            break
          end
        end
      end
      break if found
    end
    equal = false if !found
  end
  equal
end

def specifics_equal?(def_el, specifics)
  equal = true
  found = false
  if !specifics.nil?
    specifics.each do |s|
      def_el.elements.each("specific") do |specific|
        if specific.get_text == s
          found = true
          break
        end
      end
      break if found
    end
  end
  equal = false if !found

  if equal
    found = false
    def_el.elements.each("specific") do |specific|
      if !specifics.nil?
        specifics.each do |s|
          if s == specific.get_text
            found = true
            break
          end
        end
      end
      break if found
    end
    equal = false if !found
  end
  equal
end

def ip_matches_equal?(def_el, ip_matches)
  equal = true
  found = false
  if !ip_matches.nil?
    ip_matches.each do |ipm|
      def_el.elements.each("ip-match") do |ip_match|
        if ip_match.get_text == ipm
          found = true
          break
        end
      end
      break if found
    end
  end
  equal = false if !found

  if equal
    found = false
    def_el.elements.each("ip-match") do |ip_match|
      if !ip_matches.nil?
        ip_matches.each do |ipm|
          if ip_match.get_text == ipm
            found = true
            break
          end
        end
        break if found
      end
    end
    equal = false if !found
  end
  equal
end

def create_wmi_config_definition
  Chef::Log.debug "Creating wmi config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  definition_el = nil
  if new_resource.position == "bottom"
    definition_el = doc.root.add_element 'definition'
  else
    first_def = doc.elements["/wmi-config/definition[1]"]
    if first_def.nil?
      definition_el = doc.root.add_element 'definition'
    else
      definition_el = REXML::Element.new 'definition'
      doc.root.insert_before(first_def, definition_el)
    end
  end
  definition_el.attributes['retry'] = new_resource.retry_count if !new_resource.retry_count.nil?
  definition_el.attributes['timeout'] = new_resource.timeout if !new_resource.timeout.nil?
  definition_el.attributes['username'] = new_resource.username if !new_resource.username.nil?
  definition_el.attributes['domain'] = new_resource.domain if !new_resource.domain.nil?
  definition_el.attributes['password'] = new_resource.password if !new_resource.password.nil?
  if !new_resource.ranges.nil?
    new_resource.ranges.each do |r_begin, r_end|
      definition_el.add_element 'range', {'begin' => r_begin, 'end' => r_end}
    end
  end
  if !new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      sel = definition_el.add_element 'specific'
      sel.add_text(specific)
    end
  end
  if !new_resource.ip_matches.nil?
    new_resource.ip_matches.each do |ip_match|
      ipm_el = definition_el.add_element 'ip-match'
      ipm_el.add_text(ip_match)
    end
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "w"){ |file| file.puts(out) }
end

def update_wmi_config_definition
  Chef::Log.debug "Updating wmi config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  def_el = matching_def(doc, new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.username,
                        new_resource.domain,
                        new_resource.password)

  # remove all ranges, specifics and ip_matches that exist already
  def_el.elements.delete_all('range')
  def_el.elements.delete_all('specific')
  def_el.elements.delete_all('ip-match')
  
  # put the new ones in
  if !new_resource.ranges.nil?
    new_resource.ranges.each do |r_begin, r_end|
      def_el.add_element 'range', {'begin' => r_begin, 'end' => r_end}
    end
  end
  if !new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      sel = def_el.add_element 'specific'
      sel.add_text(specific)
    end
  end
  if !new_resource.ip_matches.nil?
    new_resource.ip_matches.each do |ip_match|
      ipm_el = def_el.add_element 'ip-match'
      ipm_el.add_text(ip_match)
    end
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "w"){ |file| file.puts(out) }
end

def delete_wmi_config_definition
  Chef::Log.info "Deleting wmi config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  def_el = matching_def(doc, new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.username,
                        new_resource.domain,
                        new_resource.password)

  doc.root.delete(def_el)

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", "w"){ |file| file.puts(out) }
end
