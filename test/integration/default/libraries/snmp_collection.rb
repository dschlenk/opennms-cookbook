# frozen_string_literal: true
require 'rexml/document'
class SnmpCollection < Inspec.resource(1)
  name 'snmp_collection'

  desc '
    OpenNMS snmp_collection
  '

  example '
    describe snmp_collection(\'baz\') do
      its(\'max_vars_per_pdu\') { should eq 75 }
      its(\'snmp_stor_flag\') { should eq \'all\' }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/datacollection-config.xml').content)
    c_el = doc.elements["/datacollection-config/snmp-collection[@name='#{name}']"]
    @exists = !c_el.nil?
    @params = {}
    if @exists
      @params[:max_vars_per_pdu] = c_el.attributes['maxVarsPerPdu'].to_i unless c_el.attributes['maxVarsPerPdu'].nil?
      @params[:snmp_stor_flag] = c_el.attributes['snmpStorageFlag'].to_s
      @params[:rrd_step] = c_el.elements['rrd'].attributes['step'].to_i
      @params[:rras] = []
      c_el.each_element('rrd/rra') do |rra|
        @params[:rras].push rra.texts.collect(&:value).join('')
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
