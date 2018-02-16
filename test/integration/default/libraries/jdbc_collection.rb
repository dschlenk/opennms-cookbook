# frozen_string_literal: true
require 'rexml/document'
class JdbcCollection < Inspec.resource(1)
  name 'jdbc_collection'

  desc '
    OpenNMS jdbc_collection
  '

  example '
    describe jdbc_collection(\'AnJDBCCollection\') do
      it { should exist }
      its(\'rrd_step\') { should eq 300 }
      its(\'rras\') { should eq([\'RRA:AVERAGE:0.5:1:2016\', \'RRA:AVERAGE:0.5:12:1488\', \'RRA:AVERAGE:0.5:288:366\', \'RRA:MAX:0.5:288:366\', \'RRA:MIN:0.5:288:366\']) }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/jdbc-datacollection-config.xml').content)
    c_el = doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{name}']"]
    @params = {}
    @params[:rrd_step] = c_el.elements['rrd'].attributes['step'].to_i
    @params[:rras] = []
    c_el.each_element('rrd/rra') do |rra|
      @params[:rras].push rra.texts.join('\n') # lord I hope no one has ever split one of these on multiple lines
    end
  end

  def method_missing(param)
    @params[param]
  end
end
