# frozen_string_literal: true
require 'json'
require 'rexml/document'

class ResourceType < Inspec.resource(1)
  name 'resource_type'

  desc '
    OpenNMS resource_type
  '

  example '
    describe resource_type(\'wibbleWobble\', \'metasyntactic\', \'resource-type.xml\') do,
      it { should exist }
      its(\'label\') { should eq \'Wibble Wobble\' }
      its(\'resource_label\') { should eq \'${wibble} - ${wobble}\' }
      its(\'persistence_selector_strategy\') { should eq \'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy\' }
      its(\'persistence_selector_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
      its(\'storage_strategy\') { should eq \'org.opennms.netmgt.collection.support.IndexStorageStrategy\' }
      its(\'storage_strategy_params\') { should eq [{ \'theKey\' => \'theValue\' }] }
    end
  '

  # On OpenNMS 36 the datacollection groups are stored in the database and
  # served by the v2 REST API; on older versions the group files live under
  # /opt/opennms/etc/datacollection. The resource-types.d files stay file
  # based on all versions
  API_BASE = 'http://localhost:8980/opennms/api/v2/datacollectionconf'
  API_AUTH = { user: 'admin', pass: 'admin' }.freeze

  def initialize(name, group_name, file_name = nil)
    # fn = find_group_file('/opt/opennms', group_name)
    return if group_name.nil? && file_name.nil?
    if group_name.nil?
      fn = "/opt/opennms/etc/resource-types.d/#{file_name}"
      xpath = "resource-types/resourceType[@name = '#{name}']"
      doc = inspec.file(fn).exist? ? REXML::Document.new(inspec.file(fn).content) : nil
      r_el = doc.elements[xpath] unless doc.nil?
    else
      doc = api_source_document([group_name, file_name])
      if doc.nil?
        fn = "/opt/opennms/etc/datacollection/#{group_name}.xml"
        doc = inspec.file(fn).exist? ? REXML::Document.new(inspec.file(fn).content) : nil
      end
      r_el = doc.elements["/datacollection-group/resourceType[@name = '#{name}']"] unless doc.nil?
    end
    @exists = !r_el.nil?
    if @exists
      @params = {}
      @params[:label] = r_el.attributes['label'].to_s
      @params[:resource_label] = r_el.attributes['resourceLabel'].to_s
      @params[:persistence_selector_strategy] = r_el.elements['persistenceSelectorStrategy'].attributes['class'].to_s
      @params[:persistence_selector_strategy_params] = []
      unless r_el.elements['persistenceSelectorStrategy/parameter'].nil?
        r_el.each_element('persistenceSelectorStrategy/parameter') do |p|
          @params[:persistence_selector_strategy_params].push(p.attributes['key'].to_s => p.attributes['value'].to_s)
        end
      end
      @params[:storage_strategy] = r_el.elements['storageStrategy'].attributes['class'].to_s
      @params[:storage_strategy_params] = []
      unless r_el.elements['storageStrategy/parameter'].nil?
        r_el.each_element('storageStrategy/parameter') do |p|
          @params[:storage_strategy_params].push(p.attributes['key'].to_s => p.attributes['value'].to_s)
        end
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  # The document of the collection source matching a group name or file
  # stem, served by the v2 REST API on OpenNMS 36: exact, then
  # case-insensitive, then alphanumeric-normalized on a unique match; nil
  # when the API is not available or no source matches
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
        c = c.end_with?('.xml') ? c[0...c.rindex('.xml')] : c
        canonical = match.call(c)
        break unless canonical.nil?
      end
      break unless canonical.nil?
    end
    if canonical.nil?
      candidates.compact.each do |c|
        c = c.end_with?('.xml') ? c[0...c.rindex('.xml')] : c
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
end
