# frozen_string_literal: true
require 'json'
require 'rexml/document'

class SnmpCollectionGroup < Inspec.resource(1)
  name 'snmp_collection_group'

  desc '
    OpenNMS snmp_collection_group
  '

  example '
    describe snmp_collection_group(\'MIB2\', \'mib2.xml\'[, \'default\']) do
      it { should exist }
      its(\'file_content\') { should eq \'...\' }
    end
  '

  # On OpenNMS 36 the profiles and collection sources are stored in the
  # database and served by the v2 REST API; on older versions the
  # include-collection entries live in
  # /opt/opennms/etc/datacollection-config.xml
  API_BASE = 'http://localhost:8980/opennms/api/v2/datacollectionconf'
  API_AUTH = { user: 'admin', pass: 'admin' }.freeze

  def initialize(group_name, file, collection = 'default')
    @group_name = group_name
    row = api_profile_row(collection)
    if row
      fill_from_api(row, file, collection)
    else
      fill_from_file(group_name, file, collection)
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end

  private

  # On OpenNMS 36 a group is attached to a profile either as a plain
  # include-collection reference (matching the canonical source name
  # case-insensitively, no exclude filters) or in materialized form: the
  # server rewrites a filtered include to a reference to a synthetic
  # __inline_<profile> source whose content is the surviving part of the
  # group, so the declared form is identified by the file's @name matching
  # the group name and the inline source carrying one of the file's
  # systemDefs (the declared filter values are not persisted)
  def fill_from_api(row, file, collection)
    @exists = false
    @params = {}
    source_names = row['sourceNames']
    references = if source_names.nil?
                   []
                 else
                   (source_names.is_a?(String) ? JSON.parse(source_names) : source_names)
                 end
    inline_name = "__inline_#{collection}"
    inline_system_defs = nil
    if references.include?(inline_name)
      inline_system_defs = api_source_system_defs(inline_name)
    end
    file_at_name = api_file_at_name(file)
    if references.any? { |r| r.casecmp(@group_name) == 0 }
      @exists = true
      @params[:system_def] = file_system_defs(file).first
      @params[:exclude_filters] = []
    elsif !file_at_name.nil? && file_at_name.casecmp(@group_name) == 0 && !inline_system_defs.nil?
      intersection = file_system_defs(file).select { |sd| inline_system_defs.include?(sd) }
      unless intersection.empty?
        @exists = true
        @params[:system_def] = intersection.first
      end
    end
    @params[:file_content] = inspec.file("/opt/opennms/etc/datacollection/#{file}").content if inspec.file("/opt/opennms/etc/datacollection/#{file}").exist?
  end

  def fill_from_file(group_name, file, collection)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/datacollection-config.xml').content)
    ic = doc.elements["/datacollection-config/snmp-collection[@name = '#{collection}']/include-collection[@dataCollectionGroup = '#{group_name}']"]
    @exists = !ic.nil?
    return unless @exists
    @params = {}
    @params[:system_def] = ic.attributes['systemDef'].to_s unless ic.attributes['systemDef'].nil?
    @params[:exclude_filters] = []
    ic.each_element('exclude-filter') do |f|
      @params[:exclude_filters].push f.texts.collect(&:value).join('')
    end
    @params[:file_content] = inspec.file("/opt/opennms/etc/datacollection/#{file}").content
    fdoc = REXML::Document.new(inspec.file("/opt/opennms/etc/datacollection/#{file}").content)
    @exists = !fdoc.elements["/datacollection-group[@name = '#{group_name}']"].nil?
  end

  # The profile row with the given name from the v2 REST API, or nil when
  # the API is not available (pre-36) or the profile does not exist
  def api_profile_row(name)
    response = inspec.http("#{API_BASE}/profiles", auth: API_AUTH)
    return unless response.status == 200

    JSON.parse(response.body).find { |p| p['name'] == name }
  rescue StandardError
    nil
  end

  # The @name attribute of the group file deployed on disk, or nil
  def api_file_at_name(file)
    fn = "/opt/opennms/etc/datacollection/#{file}"
    return unless inspec.file(fn).exist?
    doc = REXML::Document.new(inspec.file(fn).content)
    doc.root.attributes['name'] unless doc.root.nil?
  rescue StandardError
    nil
  end

  # The systemDef names of a deployed group file, or []
  def file_system_defs(file)
    fn = "/opt/opennms/etc/datacollection/#{file}"
    return [] unless inspec.file(fn).exist?
    doc = REXML::Document.new(inspec.file(fn).content)
    system_defs = []
    doc.root.each_element('systemDef') do |sd|
      system_defs.push(sd.attributes['name'])
    end unless doc.root.nil?
    system_defs
  rescue StandardError
    []
  end

  # The systemDef names of a collection source served by the v2 REST API,
  # or nil when the source does not exist
  def api_source_system_defs(source_name)
    response = inspec.http("#{API_BASE}/collectsources/names-and-ids", auth: API_AUTH)
    return unless response.status == 200
    entry = JSON.parse(response.body).find { |e| e['name'] == source_name }
    return unless entry
    response = inspec.http("#{API_BASE}/collectsources/#{entry['id']}/download?format=xml", auth: API_AUTH)
    return unless response.status == 200
    system_defs = []
    doc = REXML::Document.new(response.body)
    doc.root.each_element('systemDef') do |sd|
      system_defs.push(sd.attributes['name'])
    end unless doc.root.nil?
    system_defs
  rescue StandardError
    nil
  end
end
