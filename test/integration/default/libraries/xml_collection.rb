# frozen_string_literal: true
require 'rexml/document'
class XmlCollection < Inspec.resource(1)
  name 'xml_collection'

  desc '
    OpenNMS xml_collection
  '

  example '
    describe xml_collection(\'foo\') do
      it { should exist }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/xml-datacollection-config.xml').content)
    c_el = doc.elements["/xml-datacollection-config/xml-collection[@name='#{name}']"]
    @exists = !c_el.nil?
    @params = {}
    if @exists
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
