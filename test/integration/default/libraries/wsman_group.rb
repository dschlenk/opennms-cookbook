# frozen_string_literal: true
require 'rexml/document'
class WsManGroup < Inspec.resource(1)
  name 'wsman_group'

  desc '
    OpenNMS wsman_group
  '

  example '
    describe wsman_group(\'wsman_test_resource\', \'foo\') do
      it { should exist }
      its(\'if_type\') { should eq \'all\' }
      its(\'recheck_interval\') { should eq 7_200_000 }
      its(\'resource_type\') { should eq \'wsman_thing\' }
      its(\'keyvalue\') { should eq \'Thing\' }
      its(\'attribs\') { should eq \'resource\' => { \'alias\' => \'resource\', \'type\' => \'string\' }, \'metric\' => { \'alias\' => \'metric\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(group_name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wsman-datacollection-config.xml').content)
    group = doc.elements["/wsman-datacollection-config/group[@name='#{group_name}']]"]
    @exists = !group.nil?
    @params = {}
    return unless @exists
    @params[:if_type] = group.attributes['ifType'].to_s
    @params[:recheck_interval] = group.attributes['recheckInterval'].to_s.to_i
    @params[:resource_type] = group.attributes['resource-type'].to_s
    @params[:resource_uri] = group.attributes['resource-uri'].to_s
    @params[:dialect] = group.attributes['dialect'].to_s
    @params[:filter] = group.attributes['filter'].to_s
    @params[:keyvalue] = group.attributes['keyvalue'].to_s

    unless group.elements['attrib'].nil?
      attribs = {}
      group.each_element('attrib') do |a|
        aname = a.attributes['name'].to_s
        atype = a.attributes['type'].to_s
        aalias = a.attributes['alias'].to_s
        aobj = a.attributes['index-of'].to_s unless a.attributes['index-of'].nil?
        minval = a.attributes['minval'].to_s unless a.attributes['minval'].nil?
        maxval = a.attributes['maxval'].to_s unless a.attributes['maxval'].nil?
        attribs[aname] = {}
        attribs[aname]['type'] = atype
        attribs[aname]['alias'] = aalias
        attribs[aname]['index-of'] = aobj unless aobj.nil?
        attribs[aname]['minval'] = minval unless minval.nil?
        attribs[aname]['maxval'] = minval unless maxval.nil?
      end
    end
    @params[:attribs] = attribs
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
