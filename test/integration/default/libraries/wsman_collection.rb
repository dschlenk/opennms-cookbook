# frozen_string_literal: true
require 'rexml/document'
class WsManCollection < Inspec.resource(1)
  name 'wsman_collection'

  desc '
    OpenNMS wsman_collection
  '

  example '
    describe opennms_wsman_collection(\'Ws-ManFoo\') do
      its(\'max_vars_per_pdu\') { should eq 50 }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wsman-datacollection-config.xml').content)
    c_el = doc.elements["/wsman-datacollection-config/collection[@name='#{name}']"]
    @exists = !c_el.nil?
    @params = {}
    if @exists
      @params[:include_system_definitions] = !c_el.elements['include-all-system-definitions'].nil?
      @params[:include_system_definition] = []
      c_el.each_element('include-system-definition') do |isd|
        @params[:include_system_definition].push isd.texts.collect(&:value).join('')
      end
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
