# frozen_string_literal: true
require 'rexml/document'
class SnmpCollectionGroup < Inspec.resource(1)
  name 'snmp_collection_group'

  desc '
    OpenNMS snmp_collection_group
  '

  example '
    describe snmp_collection_group(\'MIB2\', \'mib2.xml\'[, \'default\']) do
      it { should exist }
    end
  '

  def initialize(group_name, file, collection = 'default')
    @group_name = group_name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/datacollection-config.xml').content)
    ic = doc.elements["/datacollection-config/snmp-collection[@name = '#{collection}']/include-collection[@dataCollectionGroup = '#{group_name}']"]
    @exists = !ic.nil?
    return unless @exists
    @params = {}
    @params[:system_def] = ic.attributes['systemDef'].to_s unless ic.attributes['systemDef'].nil?
    @params[:exclude_filters] = []
    ic.each_element('exclude-filter') do |f|
      @params[:exclude_filters].push f.texts.join('')
    end
    fdoc = REXML::Document.new(inspec.file("/opt/opennms/etc/datacollection/#{file}").content)
    @exists = !fdoc.elements["/datacollection-group[@name = '#{group_name}']"].nil?
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
