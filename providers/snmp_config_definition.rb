def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - does it need updating?."
    if @current_resource.different
      converge_by("Update #{@new_resource}") do
        update_snmp_config_definition
        new_resource.updated_by_last_action(true)
      end
    else
        Chef::Log.info "#{@new_resource} hasn't changed - nothing to do."
    end
  else
    converge_by("Create #{ @new_resource }") do
      create_snmp_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_snmp_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{ @new_resource } doesn't exist - nothing to do."
  else
    converge_by("Delete #{ @new_resource }") do
      delete_snmp_config_definition
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSnmpConfigDefinition.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.port(@new_resource.port) unless @new_resource.port.nil?
  @current_resource.retry_count(@new_resource.retry_count) unless @new_resource.retry_count.nil?
  @current_resource.timeout(@new_resource.timeout) unless @new_resource.timeout.nil?
  @current_resource.read_community(@new_resource.read_community) unless @new_resource.read_community.nil?
  @current_resource.write_community(@new_resource.write_community) unless @new_resource.write_community.nil?
  @current_resource.proxy_host(@new_resource.proxy_host) unless @new_resource.proxy_host.nil?
  @current_resource.version(@new_resource.version) unless @new_resource.version.nil?
  @current_resource.max_vars_per_pdu(@new_resource.max_vars_per_pdu) unless @new_resource.max_vars_per_pdu.nil?
  @current_resource.max_repetitions(@new_resource.max_repetitions) unless @new_resource.max_repetitions.nil?
  @current_resource.max_request_size(@new_resource.max_request_size) unless @new_resource.max_request_size.nil?
  @current_resource.security_name(@new_resource.security_name) unless @new_resource.security_name.nil?
  @current_resource.security_level(@new_resource.security_level) unless @new_resource.security_level.nil?
  @current_resource.auth_passphrase(@new_resource.auth_passphrase) unless @new_resource.auth_passphrase.nil?
  @current_resource.auth_protocol(@new_resource.auth_protocol) unless @new_resource.auth_protocol.nil?
  @current_resource.engine_id(@new_resource.engine_id) unless @new_resource.engine_id.nil?
  @current_resource.context_engine_id(@new_resource.context_engine_id) unless @new_resource.context_engine_id.nil?
  @current_resource.context_name(@new_resource.context_name) unless @new_resource.context_name.nil?
  @current_resource.privacy_passphrase(@new_resource.privacy_passphrase) unless @new_resource.privacy_passphrase.nil?
  @current_resource.privacy_protocol(@new_resource.privacy_protocol) unless @new_resource.privacy_protocol.nil?
  @current_resource.enterprise_id(@new_resource.enterprise_id) unless @new_resource.enterprise_id.nil?
  @current_resource.ranges(@new_resource.ranges) unless @new_resource.ranges.nil?
  @current_resource.specifics(@new_resource.specifics) unless @new_resource.specifics.nil?
  @current_resource.ip_matches(@new_resource.ip_matches) unless @new_resource.ip_matches.nil?

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "r")
  contents = file.read
  file.close

  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 
  def_el = matching_def(doc, @current_resource.port, 
                        @current_resource.retry_count,
                        @current_resource.timeout, 
                        @current_resource.read_community, 
                        @current_resource.write_community, 
                        @current_resource.proxy_host, 
                        @current_resource.version, 
                        @current_resource.max_vars_per_pdu, 
                        @current_resource.max_repetitions, 
                        @current_resource.max_request_size, 
                        @current_resource.security_name, 
                        @current_resource.security_level, 
                        @current_resource.auth_passphrase,  
                        @current_resource.auth_protocol, 
                        @current_resource.engine_id, 
                        @current_resource.context_engine_id, 
                        @current_resource.context_name, 
                        @current_resource.privacy_passphrase, 
                        @current_resource.privacy_protocol, 
                        @current_resource.enterprise_id)
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

def matching_def(doc, port, retry_count, timeout, read_community, 
                 write_community, proxy_host, version, max_vars_per_pdu, 
                 max_repetitions, max_request_size, security_name, 
                 security_level, auth_passphrase, auth_protocol, 
                 engine_id, context_engine_id, context_name, 
                 privacy_passphrase, privacy_protocol, enterprise_id)

  definition = nil
  doc.elements.each("/snmp-config/definition") do |def_el|
    if "#{def_el.attributes['port']}" == "#{port}"\
    && "#{def_el.attributes['retry']}" == "#{retry_count}"\
    && "#{def_el.attributes['timeout']}" == "#{timeout}"\
    && "#{def_el.attributes['read-community']}" == "#{read_community}"\
    && "#{def_el.attributes['write-community']}" == "#{write_community}"\
    && "#{def_el.attributes['proxy-host']}"== "#{proxy_host}"\
    && "#{def_el.attributes['version']}" == "#{version}"\
    && "#{def_el.attributes['max-vars-per-pdu']}" == "#{max_vars_per_pdu}"\
    && "#{def_el.attributes['max-repetitions']}" == "#{max_repetitions}"\
    && "#{def_el.attributes['max-request-size']}" == "#{max_request_size}"\
    && "#{def_el.attributes['security-name']}" == "#{security_name}"\
    && "#{def_el.attributes['security-level']}" == "#{security_level}"\
    && "#{def_el.attributes['auth-passphrase']}" == "#{auth_passphrase}"\
    && "#{def_el.attributes['auth-protocol']}" == "#{auth_protocol}"\
    && "#{def_el.attributes['engine-id']}" == "#{engine_id}"\
    && "#{def_el.attributes['context-engine-id']}" == "#{context_engine_id}"\
    && "#{def_el.attributes['context-name']}" == "#{context_name}"\
    && "#{def_el.attributes['privacy-passphrase']}" == "#{privacy_passphrase}"\
    && "#{def_el.attributes['privacy-protocol']}" == "#{privacy_protocol}"\
    && "#{def_el.attributes['enterprise-id']}" == "#{enterprise_id}"
      definition = def_el
      break
    end
  end
  definition
end

def ranges_equal?(def_el, ranges)
  Chef::Log.debug("Check for no ranges: #{def_el.elements["range"].nil?} && #{ranges}")
  return true if def_el.elements["range"].nil? && (ranges.nil? || ranges.length == 0)
  curr_ranges = {}
  def_el.elements.each('range') do |r_el|
    curr_ranges[r_el.attributes['begin']] = r_el.attributes['end']
  end
  return curr_ranges == ranges
end

def specifics_equal?(def_el, specifics)
  Chef::Log.debug("Check for no specifics: #{def_el.elements["specific"].nil?} && #{specifics}")
  return true if def_el.elements["specific"].nil? && (specifics.nil? || specifics.length == 0)
  curr_specifics = []
  def_el.elements.each("specific") do |specific|
    curr_specifics.push specific.text
  end
  curr_specifics.sort!
  Chef::Log.debug("specifics equal? #{curr_specifics} == #{specifics}")
  sorted_specifics = nil
  sorted_specifics = specifics.sort unless specifics.nil?
  return curr_specifics == sorted_specifics
end

def ip_matches_equal?(def_el, ip_matches)
  Chef::Log.debug("Check for no ip_matches: #{def_el.elements["ip-match"].nil?} && #{ip_matches.nil?}")
  return true if def_el.elements["ip-match"].nil? && (ip_matches.nil? || ip_matches.length == 0)
  curr_ipm = []
  def_el.elements.each("ip-match") do |ipm|
    curr_ipm.push ipm.text
  end
  curr_ipm.sort!
  Chef::Log.debug("ip matches equal? #{curr_ipm} == #{ip_matches}")
  sorted_ipm = nil
  sorted_ipm = ip_matches.sort unless ip_matches.nil?
  return curr_ipm == sorted_ipm
end

def create_snmp_config_definition
  Chef::Log.debug "Creating snmp config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  definition_el = nil
  if new_resource.position == "bottom"
    definition_el = doc.root.add_element 'definition'
  else
    first_def = doc.elements["/snmp-config/definition[1]"]
    if first_def.nil?
      definition_el = doc.root.add_element 'definition'
    else
      definition_el = REXML::Element.new 'definition'
      doc.root.insert_before(first_def, definition_el)
    end
  end
  definition_el.attributes['port'] = new_resource.port if !new_resource.port.nil?
  definition_el.attributes['retry'] = new_resource.retry_count if !new_resource.retry_count.nil?
  definition_el.attributes['timeout'] = new_resource.timeout if !new_resource.timeout.nil?
  definition_el.attributes['read-community'] = new_resource.read_community if !new_resource.read_community.nil?
  definition_el.attributes['write-community'] = new_resource.write_community if !new_resource.write_community.nil?
  definition_el.attributes['proxy-host'] = new_resource.proxy_host if !new_resource.proxy_host.nil?
  definition_el.attributes['version'] = new_resource.version if !new_resource.version.nil?
  definition_el.attributes['max-vars-per-pdu'] = new_resource.max_vars_per_pdu if !new_resource.max_vars_per_pdu.nil?
  definition_el.attributes['max-repetitions'] = new_resource.max_repetitions if !new_resource.max_repetitions.nil?
  definition_el.attributes['max-request-size'] = new_resource.max_request_size if !new_resource.max_request_size.nil?
  definition_el.attributes['security-name'] = new_resource.security_name if !new_resource.security_name.nil?
  definition_el.attributes['security-level'] = new_resource.security_level if !new_resource.security_level.nil?
  definition_el.attributes['auth-passphrase'] = new_resource.auth_passphrase if !new_resource.auth_passphrase.nil?
  definition_el.attributes['auth-protocol'] = new_resource.auth_protocol if !new_resource.auth_protocol.nil?
  definition_el.attributes['engine-id'] = new_resource.engine_id if !new_resource.engine_id.nil?
  definition_el.attributes['context-engine-id'] = new_resource.context_engine_id if !new_resource.context_engine_id.nil?
  definition_el.attributes['context-name'] = new_resource.context_name if !new_resource.context_name.nil?
  definition_el.attributes['privacy-passphrase'] = new_resource.privacy_passphrase if !new_resource.privacy_passphrase.nil?
  definition_el.attributes['privacy-protocol'] = new_resource.privacy_protocol if !new_resource.privacy_protocol.nil?
  definition_el.attributes['enterprise-id'] = new_resource.enterprise_id if !new_resource.enterprise_id.nil?
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
  ::File.open("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "w"){ |file| file.puts(out) }
end

def update_snmp_config_definition
  Chef::Log.debug "Updating snmp config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  def_el = matching_def(doc, new_resource.port,
                        new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.read_community,
                        new_resource.write_community,
                        new_resource.proxy_host,
                        new_resource.version,
                        new_resource.max_vars_per_pdu,
                        new_resource.max_repetitions,
                        new_resource.max_request_size,
                        new_resource.security_name,
                        new_resource.security_level,
                        new_resource.auth_passphrase,
                        new_resource.auth_protocol,
                        new_resource.engine_id,
                        new_resource.context_engine_id,
                        new_resource.context_name,
                        new_resource.privacy_passphrase,
                        new_resource.privacy_protocol,
                        new_resource.enterprise_id)

  # put the new ones in
  if !new_resource.ranges.nil?
    new_resource.ranges.each do |r_begin, r_end|
      if !def_el.nil? && def_el.elements["range[@begin = '#{r_begin}' and @end = '#{r_end}']"].nil?
        def_el.add_element 'range', {'begin' => r_begin, 'end' => r_end}
      end
    end
  end
  if !new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      if def_el.elements["specific[text() = '#{specific}']"].nil?
        sel = def_el.add_element 'specific'
        sel.add_text(specific)
      end
    end
  end
  if !new_resource.ip_matches.nil?
    new_resource.ip_matches.each do |ip_match|
      if def_el.elements["ip-match[text() = '#{ip_match}']"].nil?
        ipm_el = def_el.add_element 'ip-match'
        ipm_el.add_text(ip_match)
      end
    end
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "w"){ |file| file.puts(out) }
end

def delete_snmp_config_definition
  Chef::Log.debug "Deleting snmp config definition : '#{ new_resource.name }'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "r")
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote 

  def_el = matching_def(doc, new_resource.port,
                        new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.read_community,
                        new_resource.write_community,
                        new_resource.proxy_host,
                        new_resource.version,
                        new_resource.max_vars_per_pdu,
                        new_resource.max_repetitions,
                        new_resource.max_request_size,
                        new_resource.security_name,
                        new_resource.security_level,
                        new_resource.auth_passphrase,
                        new_resource.auth_protocol,
                        new_resource.engine_id,
                        new_resource.context_engine_id,
                        new_resource.context_name,
                        new_resource.privacy_passphrase,
                        new_resource.privacy_protocol,
                        new_resource.enterprise_id)
    doc.root.delete(def_el)

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", "w"){ |file| file.puts(out) }
end
