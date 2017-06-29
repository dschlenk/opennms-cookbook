# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - does it need updating?."
    if @current_resource.different
      converge_by("Update #{@new_resource}") do
        update_snmp_config_definition
      end
    else
      Chef::Log.info "#{@new_resource} hasn't changed - nothing to do."
    end
  else
    converge_by("Create #{@new_resource}") do
      create_snmp_config_definition
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_snmp_config_definition
    end
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else
    converge_by("Delete #{@new_resource}") do
      delete_snmp_config_definition
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

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", 'r')
  contents = file.read
  file.close

  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  def_el = matching_def(doc, @current_resource)
  if !def_el.nil?
    @current_resource.exists = true
    @current_resource.different = if ranges_equal?(def_el, @current_resource.ranges)\
    && specifics_equal?(def_el, @current_resource.specifics)\
    && ip_matches_equal?(def_el, @current_resource.ip_matches)
                                    false
                                  else
                                    true
                                  end
  else
    @current_resource.different = true
  end
end

private

def matching_def(doc, current_resource)
  definition = nil
  doc.elements.each('/snmp-config/definition') do |def_el|
    next unless def_el.attributes['port'].to_s == current_resource.port.to_s\
    && def_el.attributes['retry'].to_s == current_resource.retry_count.to_s\
    && def_el.attributes['timeout'].to_s == current_resource.timeout.to_s\
    && def_el.attributes['read-community'].to_s == current_resource.read_community.to_s\
    && def_el.attributes['write-community'].to_s == current_resource.write_community.to_s\
    && def_el.attributes['proxy-host'].to_s == current_resource.proxy_host.to_s\
    && def_el.attributes['version'].to_s == current_resource.version.to_s\
    && def_el.attributes['max-vars-per-pdu'].to_s == current_resource.max_vars_per_pdu.to_s\
    && def_el.attributes['max-repetitions'].to_s == current_resource.max_repetitions.to_s\
    && def_el.attributes['max-request-size'].to_s == current_resource.max_request_size.to_s\
    && def_el.attributes['security-name'].to_s == current_resource.security_name.to_s\
    && def_el.attributes['security-level'].to_s == current_resource.security_level.to_s\
    && def_el.attributes['auth-passphrase'].to_s == current_resource.auth_passphrase.to_s\
    && def_el.attributes['auth-protocol'].to_s == current_resource.auth_protocol.to_s\
    && def_el.attributes['engine-id'].to_s == current_resource.engine_id.to_s\
    && def_el.attributes['context-engine-id'].to_s == current_resource.context_engine_id.to_s\
    && def_el.attributes['context-name'].to_s == current_resource.context_name.to_s\
    && def_el.attributes['privacy-passphrase'].to_s == current_resource.privacy_passphrase.to_s\
    && def_el.attributes['privacy-protocol'].to_s == current_resource.privacy_protocol.to_s\
    && def_el.attributes['enterprise-id'].to_s == current_resource.enterprise_id.to_s
    definition = def_el
    break
  end
  definition
end

def ranges_equal?(def_el, ranges)
  Chef::Log.debug("Check for no ranges: #{def_el.elements['range'].nil?} && #{ranges}")
  return true if def_el.elements['range'].nil? && (ranges.nil? || ranges.empty?)
  curr_ranges = {}
  def_el.elements.each('range') do |r_el|
    curr_ranges[r_el.attributes['begin']] = r_el.attributes['end']
  end
  curr_ranges == ranges
end

def specifics_equal?(def_el, specifics)
  Chef::Log.debug("Check for no specifics: #{def_el.elements['specific'].nil?} && #{specifics}")
  return true if def_el.elements['specific'].nil? && (specifics.nil? || specifics.empty?)
  curr_specifics = []
  def_el.elements.each('specific') do |specific|
    curr_specifics.push specific.text
  end
  curr_specifics.sort!
  Chef::Log.debug("specifics equal? #{curr_specifics} == #{specifics}")
  sorted_specifics = nil
  sorted_specifics = specifics.sort unless specifics.nil?
  curr_specifics == sorted_specifics
end

def ip_matches_equal?(def_el, ip_matches)
  Chef::Log.debug("Check for no ip_matches: #{def_el.elements['ip-match'].nil?} && #{ip_matches.nil?}")
  return true if def_el.elements['ip-match'].nil? && (ip_matches.nil? || ip_matches.empty?)
  curr_ipm = []
  def_el.elements.each('ip-match') do |ipm|
    curr_ipm.push ipm.text
  end
  curr_ipm.sort!
  Chef::Log.debug("ip matches equal? #{curr_ipm} == #{ip_matches}")
  sorted_ipm = nil
  sorted_ipm = ip_matches.sort unless ip_matches.nil?
  curr_ipm == sorted_ipm
end

def create_snmp_config_definition
  Chef::Log.debug "Creating snmp config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  definition_el = nil
  if new_resource.position == 'bottom'
    definition_el = doc.root.add_element 'definition'
  else
    first_def = doc.elements['/snmp-config/definition[1]']
    if first_def.nil?
      definition_el = doc.root.add_element 'definition'
    else
      definition_el = REXML::Element.new 'definition'
      doc.root.insert_before(first_def, definition_el)
    end
  end
  definition_el.attributes['port'] = new_resource.port unless new_resource.port.nil?
  definition_el.attributes['retry'] = new_resource.retry_count unless new_resource.retry_count.nil?
  definition_el.attributes['timeout'] = new_resource.timeout unless new_resource.timeout.nil?
  definition_el.attributes['read-community'] = new_resource.read_community unless new_resource.read_community.nil?
  definition_el.attributes['write-community'] = new_resource.write_community unless new_resource.write_community.nil?
  definition_el.attributes['proxy-host'] = new_resource.proxy_host unless new_resource.proxy_host.nil?
  definition_el.attributes['version'] = new_resource.version unless new_resource.version.nil?
  definition_el.attributes['max-vars-per-pdu'] = new_resource.max_vars_per_pdu unless new_resource.max_vars_per_pdu.nil?
  definition_el.attributes['max-repetitions'] = new_resource.max_repetitions unless new_resource.max_repetitions.nil?
  definition_el.attributes['max-request-size'] = new_resource.max_request_size unless new_resource.max_request_size.nil?
  definition_el.attributes['security-name'] = new_resource.security_name unless new_resource.security_name.nil?
  definition_el.attributes['security-level'] = new_resource.security_level unless new_resource.security_level.nil?
  definition_el.attributes['auth-passphrase'] = new_resource.auth_passphrase unless new_resource.auth_passphrase.nil?
  definition_el.attributes['auth-protocol'] = new_resource.auth_protocol unless new_resource.auth_protocol.nil?
  definition_el.attributes['engine-id'] = new_resource.engine_id unless new_resource.engine_id.nil?
  definition_el.attributes['context-engine-id'] = new_resource.context_engine_id unless new_resource.context_engine_id.nil?
  definition_el.attributes['context-name'] = new_resource.context_name unless new_resource.context_name.nil?
  definition_el.attributes['privacy-passphrase'] = new_resource.privacy_passphrase unless new_resource.privacy_passphrase.nil?
  definition_el.attributes['privacy-protocol'] = new_resource.privacy_protocol unless new_resource.privacy_protocol.nil?
  definition_el.attributes['enterprise-id'] = new_resource.enterprise_id unless new_resource.enterprise_id.nil?
  unless new_resource.ranges.nil?
    new_resource.ranges.each do |r_begin, r_end|
      definition_el.add_element 'range', 'begin' => r_begin, 'end' => r_end
    end
  end
  unless new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      sel = definition_el.add_element 'specific'
      sel.add_text(specific)
    end
  end
  unless new_resource.ip_matches.nil?
    new_resource.ip_matches.each do |ip_match|
      ipm_el = definition_el.add_element 'ip-match'
      ipm_el.add_text(ip_match)
    end
  end
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
end

def update_snmp_config_definition
  Chef::Log.debug "Updating snmp config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  def_el = matching_def(doc, new_resource)

  # put the new ones in
  unless new_resource.ranges.nil?
    new_resource.ranges.each do |r_begin, r_end|
      if !def_el.nil? && def_el.elements["range[@begin = '#{r_begin}' and @end = '#{r_end}']"].nil?
        def_el.add_element 'range', 'begin' => r_begin, 'end' => r_end
      end
    end
  end
  unless new_resource.specifics.nil?
    new_resource.specifics.each do |specific|
      if def_el.elements["specific[text() = '#{specific}']"].nil?
        sel = def_el.add_element 'specific'
        sel.add_text(specific)
      end
    end
  end
  unless new_resource.ip_matches.nil?
    new_resource.ip_matches.each do |ip_match|
      if def_el.elements["ip-match[text() = '#{ip_match}']"].nil?
        ipm_el = def_el.add_element 'ip-match'
        ipm_el.add_text(ip_match)
      end
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
end

def delete_snmp_config_definition
  Chef::Log.debug "Deleting snmp config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  def_el = matching_def(doc, new_resource)
  doc.root.delete(def_el)

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
end
