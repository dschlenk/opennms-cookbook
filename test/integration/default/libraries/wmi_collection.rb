# frozen_string_literal: true
require 'rexml/document'
class WmiCollection < Inspec.resource(1)
  name 'wmi_collection'

  desc '
    OpenNMS wmi_collection
  '

  example '
    describe wmi_collection(\'foo\') do
      its(\'max_vars_per_pdu\') { should eq 50 }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wmi-datacollection-config.xml').content)
    c_el = doc.elements["/wmi-datacollection-config/wmi-collection[@name='#{name}']"]
    @exists = !c_el.nil?
    @params = {}
    if @exists
      @params[:max_vars_per_pdu] = c_el.attributes['maxVarsPerPdu'].to_i
      @params[:rrd_step] = c_el.elements['rrd'].attributes['step'].to_i
      @params[:rras] = []
      c_el.each_element('rrd/rra') do |rra|
        @params[:rras].push rra.texts.join('')
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
