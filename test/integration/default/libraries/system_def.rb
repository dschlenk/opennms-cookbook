# frozen_string_literal: true
require 'json'
require 'rexml/document'

class SystemDef < Inspec.resource(1)
  name 'system_def'

  desc '
    OpenNMS system_def
  '

  example '
    describe system_def(\'Cisco Routers\') do
      it { should exist }
      its(\'groups\') { should eq [\'mib2-tcp\', \'mib2-powerethernet\'] }
    end
  '

  # On OpenNMS 36 the system definitions live in the database collection
  # source named after the file and are served by the v2 REST API; on
  # older versions they live in the files under
  # /opt/opennms/etc/datacollection
  API_BASE = 'http://localhost:8980/opennms/api/v2/datacollectionconf'
  API_AUTH = { user: 'admin', pass: 'admin' }.freeze

  def initialize(name, file = nil)
    fn = file.nil? ? nil : "/opt/opennms/etc/datacollection/#{file}"
    # On OpenNMS 36 the system definitions live in the database and are
    # served by the v2 REST API; the group files under
    # /opt/opennms/etc/datacollection are retained on the 36 image but not
    # read by OpenNMS, so they are only consulted when the API is not
    # available (pre-36). A system definition missing from an existing
    # source is absent, even when the legacy file still contains it
    api = api_system_def_element(name, file)
    s_el = api
    if api == :no_api
      s_el = nil
      if file.nil?
        fn = find_system_def_file(name)
        unless fn.nil?
          doc = REXML::Document.new(inspec.file(fn).content)
          s_el = doc.elements["/datacollection-group/systemDef[@name='#{name}']"]
        end
      else
        s_el = file_system_def_element(name, fn)
      end
    end
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    @params[:file_name] = fn
    unless s_el.elements['collect/includeGroup'].nil?
      @params[:groups] = []
      s_el.each_element('collect/includeGroup') do |g|
        @params[:groups].push g.texts.collect(&:value).join('')
      end
    end
    @params[:sysoid] = s_el.elements['sysoid'].texts.collect(&:value).join('') unless s_el.elements['sysoid'].nil?
    @params[:sysoid_mask] = s_el.elements['sysoidMask'].texts.collect(&:value).join('') unless s_el.elements['sysoidMask'].nil?
    @params[:ip_addrs] = [] unless s_el.elements['ipList/ipAddr'].nil?
    s_el.each_element('ipList/ipAddr') do |ip|
      @params[:ip_addrs].push ip.texts.collect(&:value).join('')
    end unless s_el.elements['ipList/ipAddr'].nil?
    @params[:ip_addr_masks] = [] unless s_el.elements['ipList/ipAddrMask'].nil?
    s_el.each_element('ipList/ipAddrMask') do |ip|
      @params[:ip_addr_masks].push ip.texts.collect(&:value).join('')
    end unless s_el.elements['ipList/ipAddrMask'].nil?
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  # The systemDef element served by the v2 REST API on OpenNMS 36: the
  # element when the API answered (nil when the systemDef does not exist),
  # or :no_api when the API is not available (pre-36). With a file argument
  # the element is looked up in the collection source named after the file
  # (the file stem resolved against the existing sources); without one every
  # collection source is searched
  def api_system_def_element(name, file)
    response = inspec.http("#{API_BASE}/collectsources/names-and-ids", auth: API_AUTH)
    return :no_api unless response.status == 200

    entries = JSON.parse(response.body)
    if file.nil?
      entries.each do |entry|
        doc = api_source_document([entry['name']])
        next if doc.nil?
        el = system_def_element(doc, name)
        return el unless el.nil?
      end
      return
    end
    stem = file.end_with?('.xml') ? file[0...file.rindex('.xml')] : file
    doc = api_source_document([stem])
    return if doc.nil?

    system_def_element(doc, name)
  rescue StandardError
    :no_api
  end

  def system_def_element(doc, name)
    el = nil
    doc.root.each_element('systemDef') do |sd|
      el = sd if sd.attributes['name'] == name
    end unless doc.root.nil?
    el
  end

  # The document of the collection source matching the given names, served
  # by the v2 REST API: exact, then case-insensitive, then
  # alphanumeric-normalized on a unique match; nil when the API is not
  # available or no source matches
  def api_source_document(candidates)
    response = inspec.http("#{API_BASE}/collectsources/names-and-ids", auth: API_AUTH)
    return unless response.status == 200
    entries = JSON.parse(response.body)
    names = entries.map { |e| e['name'] }
    canonical = nil
    [
      ->(c) { names.find { |n| n == c } },
      ->(c) { names.find { |n| n.casecmp(c) == 0 } },
    ].each do |match|
      candidates.compact.each do |c|
        canonical = match.call(c)
        break unless canonical.nil?
      end
      break unless canonical.nil?
    end
    if canonical.nil?
      candidates.compact.each do |c|
        alnum = c.downcase.gsub(/[^a-z0-9]/, '')
        next if alnum.empty?
        matches = names.select { |n| n.downcase.gsub(/[^a-z0-9]/, '') == alnum }
        canonical = matches.first if matches.one?
        break unless canonical.nil?
      end
    end
    return unless canonical
    entry = entries.find { |e| e['name'] == canonical }
    response = inspec.http("#{API_BASE}/collectsources/#{entry['id']}/download?format=xml", auth: API_AUTH)
    return unless response.status == 200

    REXML::Document.new(response.body)
  rescue StandardError
    nil
  end

  def file_system_def_element(name, fn)
    return unless inspec.file(fn).exist?
    doc = REXML::Document.new(inspec.file(fn).content)
    doc.elements["/datacollection-group/systemDef[@name='#{name}']"]
  rescue StandardError
    nil
  end

  def find_system_def_file(name)
    files = inspec.command('ls -1 /opt/opennms/etc/datacollection').stdout
    files.each_line do |group|
      group.chomp!
      next if group !~ /.*\.xml$/
      file = inspec.file("/opt/opennms/etc/datacollection/#{group}").content
      doc = REXML::Document.new file
      exists = !doc.elements["/datacollection-group/systemDef[@name='#{name}']"].nil?
      if exists
        return "/opt/opennms/etc/datacollection/#{group}"
      end
    end
    nil
  end
end
