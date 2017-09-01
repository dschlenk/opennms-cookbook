# frozen_string_literal: true
require 'rexml/document'
class CollectionPackage < Inspec.resource(1)
  name 'collection_package'

  desc '
    OpenNMS collection_package
  '

  example '
    describe collection_package(\'example1\') do
      its(\'filter\') { should eq \'IPADDR != \\\'0.0.0.0\\\'\' }
      its(\'include_ranges\') { should eq [{\'begin\' => \'1.1.1.1\', \'end\' => \'254.254.254.254\'}, {\'begin\' => \'::1\', \'end\' => \'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff\'}]}
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/collectd-configuration.xml').content)
    p_el = doc.elements["/collectd-configuration/package[@name = '#{@name}']"]
    @params = {}
    @params[:filter] = p_el.elements['filter'].text.to_s
    @params[:include_ranges] = []
    p_el.each_element('include-range') do |ir|
      @params[:include_ranges].push 'begin' => ir.attributes['begin'], 'end' => ir.attributes['end']
    end
    @params[:exclude_ranges] = []
    p_el.each_element('exclude-range') do |er|
      @params[:exclude_ranges].push 'begin' => er.attributes['begin'], 'end' => er.attributes['end']
    end
    @params[:specifics] = []
    p_el.each_element('specific') do |s|
      @params[:specifics].push s.text.to_s
    end
    @params[:include_urls] = []
    p_el.each_element('include-url') do |iu|
      @params[:include_urls].push iu.text.to_s
    end
    @params[:store_by_if_alias] = false
    @params[:store_by_if_alias] = true unless p_el.elements["storeByIfAlias[contains(., 'true')]"].nil?
    @params[:store_by_node_id] = false
    @params[:store_by_node_id] = true unless p_el.elements["storeByNodeID[contains(., 'true')]"].nil?
    @params[:if_alias_domain] = name
    unless p_el.elements['ifAliasDomain'].nil?
      @params[:if_alias_domain] = p_el.elements['ifAliasDomain'].text.to_s
    end
    @params[:stor_flag_override] = false
    @params[:stor_flag_override] = true unless p_el.elements["storFlagOverride[contains(., 'true')]"].nil?
    @params[:if_alias_comment] = p_el.elements['ifAliasComment'].text.to_s unless p_el.elements['ifAliasComment'].nil?
  end

  def method_missing(param)
    @params[param]
  end
end
