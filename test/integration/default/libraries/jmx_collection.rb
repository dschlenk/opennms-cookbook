# frozen_string_literal: true
require 'rexml/document'
class JmxCollection < Inspec.resource(1)
  name 'jmx_collection'

  desc '
    OpenNMS jmx_collection
  '

  example '
    describe jmx_collection(\'jmxcollection\') do
      it { should exist }
      its(\'rrd_step\') { should eq 300 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:1:2016\', \'RRA:AVERAGE:0.5:12:1488\', \'RRA:AVERAGE:0.5:288:366\', \'RRA:MAX:0.5:288:366\', \'RRA:MIN:0.5:288:366\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/jmx-datacollection-config.xml').content)
    return if doc.nil?
    c_el = doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{name}']"]
    @exists = !c_el.nil?
    @params = {}
    if @exists
      @params[:rrd_step] = c_el.elements['rrd'].attributes['step'].to_i
      @params[:rras] = []
      c_el.each_element('rrd/rra') do |rra|
        @params[:rras].push rra.texts.join('') # lord I hope no one has ever split one of these on multiple lines
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
