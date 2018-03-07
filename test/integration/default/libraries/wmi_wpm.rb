# frozen_string_literal: true
require 'rexml/document'
class WmiWpm < Inspec.resource(1)
  name 'wmi_wpm'

  desc '
    OpenNMS wmi_wpm
  '

  example '
    describe wmi_wpm(\'wmi_test_resource\', \'foo\') do
      it { should exist }
      its(\'if_type\') { should eq \'all\' }
      its(\'recheck_interval\') { should eq 7_200_000 }
      its(\'resource_type\') { should eq \'wmi_thing\' }
      its(\'keyvalue\') { should eq \'Thing\' }
      its(\'wmi_class\') { should eq \'Win32_PerfFormattedData_PerfOS_Resource\' }
      its(\'wmi_namespace\') { should eq \'root/cimv2\' }
      its(\'attribs\') { should eq \'resource\' => { \'alias\' => \'resource\', \'type\' => \'string\' }, \'metric\' => { \'alias\' => \'metric\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(name, collection)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wmi-datacollection-config.xml').content)
    wpm = doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{collection}']/wpms/wpm[@name='#{name}']"]
    @exists = !wpm.nil?
    @params = {}
    return unless @exists
    @params[:if_type] = wpm.attributes['ifType'].to_s
    @params[:recheck_interval] = wpm.attributes['recheckInterval'].to_s.to_i
    @params[:resource_type] = wpm.attributes['resourceType'].to_s
    @params[:keyvalue] = wpm.attributes['keyvalue'].to_s
    @params[:wmi_class] = wpm.attributes['wmiClass'].to_s
    @params[:wmi_namespace] = wpm.attributes['wmiNamespace'].to_s unless wpm.attributes['wmiNamespace'].nil?
    unless wpm.elements['attrib'].nil?
      attribs = {}
      wpm.each_element('attrib') do |a|
        aname = a.attributes['name'].to_s
        atype = a.attributes['type'].to_s
        aalias = a.attributes['alias'].to_s
        aobj = a.attributes['wmiObject'].to_s unless a.attributes['wmiObject'].nil?
        minval = a.attributes['minval'].to_s unless a.attributes['minval'].nil?
        maxval = a.attributes['maxval'].to_s unless a.attributes['maxval'].nil?
        attribs[aname] = {}
        attribs[aname]['type'] = atype
        attribs[aname]['alias'] = aalias
        attribs[aname]['wmi_object'] = aobj unless aobj.nil?
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
