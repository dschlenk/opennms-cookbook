# frozen_string_literal: true
require 'rexml/document'
class WsManGroup < Inspec.resource(1)
  name 'wsman_group'

  desc '
    OpenNMS wsman_group
  '

  example '
    describe wsman_group(\'wmi_test_resource\') do
      it { should exist }
      its(\'resource_type\') { should eq \'resource_type\' }
      its(\'resource_uri\') { should eq \'resource_uri\' }
      its(\'dialect\') { should eq \'dialect\' }
      its(\'filter\') { should eq \'filter\' }
      its(\'attribs\') { should eq \'resource\' => { \'alias\' => \'resource\', \'type\' => \'string\' }, \'metric\' => { \'alias\' => \'metric\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(group_name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wsman-datacollection-config.xml').content)
    wsman_group = doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']]"]
    if wsman_group.nil?
      doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wsman-datacollection.d/wsman-test-group.xml').content)
      wsman_group = doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']]"]
    end
    @exists = !wsman_group?
    @params = {}
    return unless @exists

    @params[:resource_type] = group.attributes['resource-type'].to_s
    @params[:resource_uri] = group.attributes['resource-uri'].to_s
    @params[:dialect] = group.attributes['dialect'].to_s
    @params[:filter] = group.attributes['filter'].to_s

    unless group.elements['attrib'].nil?
      attribs = {}
      group.each_element('attrib') do |a|
        aname = a.attributes['name'].to_s
        atype = a.attributes['type'].to_s
        aalias = a.attributes['alias'].to_s
        aobj = a.attributes['index-of'].to_s unless a.attributes['index-of'].nil?

        attribs[aname] = {}
        attribs[atype]['type'] = atype
        attribs[aalias]['alias'] = aalias
        attribs[aobj]['index-of'] = aobj unless aobj.nil?
      end
    end
    @params[:attribs] = attribs
  end

  def exist?
    @group_exists
  end

  def method_missing(param)
    @params[param]
  end
end
