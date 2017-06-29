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
        update_wmi_config_definition
      end
    else
      Chef::Log.info "#{@new_resource} hasn't changed - nothing to do."
    end
  else
    converge_by("Create #{@new_resource}") do
      create_wmi_config_definition
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_wmi_config_definition
    end
  end
end

action :delete do
  if !@current_resource.exists
    Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
  else
    converge_by("Delete #{@new_resource}") do
      delete_wmi_config_definition
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsWmiConfigDefinition.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.retry_count(@new_resource.retry_count) unless @new_resource.retry_count.nil?
  @current_resource.timeout(@new_resource.timeout) unless @new_resource.timeout.nil?
  @current_resource.username(@new_resource.username) unless @new_resource.username.nil?
  @current_resource.domain(@new_resource.domain) unless @new_resource.domain.nil?
  @current_resource.password(@new_resource.password) unless @new_resource.password.nil?

  @current_resource.ranges(@new_resource.ranges) unless @new_resource.ranges.nil?
  @current_resource.specifics(@new_resource.specifics) unless @new_resource.specifics.nil?
  @current_resource.ip_matches(@new_resource.ip_matches) unless @new_resource.ip_matches.nil?

  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", 'r')
  contents = file.read
  file.close

  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  def_el = matching_def(doc, @current_resource.retry_count,
                        @current_resource.timeout,
                        @current_resource.username,
                        @current_resource.domain,
                        @current_resource.password)
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

# rubocop:disable Metrics/ParameterLists
def matching_def(doc, retry_count, timeout, username, domain, password)
  definition = nil
  doc.elements.each('/wmi-config/definition') do |def_el|
    next unless def_el.attributes['retry'].to_s == retry_count.to_s\
    && def_el.attributes['timeout'].to_s == timeout.to_s\
    && def_el.attributes['username'].to_s == username.to_s\
    && def_el.attributes['domain'].to_s == domain.to_s\
    && def_el.attributes['password'].to_s == password.to_s
    definition = def_el
    break
  end
  definition
end
# rubocop:enable Metrics/ParameterLists

def ranges_equal?(def_el, ranges)
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

def create_wmi_config_definition
  Chef::Log.debug "Creating wmi config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  definition_el = nil
  if new_resource.position == 'bottom'
    definition_el = doc.root.add_element 'definition'
  else
    first_def = doc.elements['/wmi-config/definition[1]']
    if first_def.nil?
      definition_el = doc.root.add_element 'definition'
    else
      definition_el = REXML::Element.new 'definition'
      doc.root.insert_before(first_def, definition_el)
    end
  end
  definition_el.attributes['retry'] = new_resource.retry_count unless new_resource.retry_count.nil?
  definition_el.attributes['timeout'] = new_resource.timeout unless new_resource.timeout.nil?
  definition_el.attributes['username'] = new_resource.username unless new_resource.username.nil?
  definition_el.attributes['domain'] = new_resource.domain unless new_resource.domain.nil?
  definition_el.attributes['password'] = new_resource.password unless new_resource.password.nil?
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
  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wmi-config.xml")
end

def update_wmi_config_definition
  Chef::Log.debug "Updating wmi config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  def_el = matching_def(doc, new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.username,
                        new_resource.domain,
                        new_resource.password)

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

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wmi-config.xml")
end

def delete_wmi_config_definition
  Chef::Log.debug "Deleting wmi config definition : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/wmi-config.xml", 'r')
  contents = file.read
  file.close
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote

  def_el = matching_def(doc, new_resource.retry_count,
                        new_resource.timeout,
                        new_resource.username,
                        new_resource.domain,
                        new_resource.password)

  doc.root.delete(def_el)

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/wmi-config.xml")
end
