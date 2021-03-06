# frozen_string_literal: true
require 'rexml/document'
class JmxMbean < Inspec.resource(1)
  name 'jmx_mbean'

  desc '
    OpenNMS jmx_mbean
  '

  example '
    describe jmx_mbean(\'org.apache.activemq.Queue\', \'jmxcollection\', \'objectname\') do
      it { should exist }
      its(\'attribs\') { should eq \'ConsumerCount\' => { \'alias\' => \'5ConsumerCnt\', \'type\' => \'gauge\' }, \'InFlightCount\' => { \'alias\' => \'5InFlightCnt\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(mbean, collection, objectname)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/jmx-datacollection-config.xml').content)
    return if doc.nil?
    m_el = doc.elements["/jmx-datacollection-config/jmx-collection[@name='#{collection}']/mbeans/mbean[@name='#{mbean}' and @objectname = '#{objectname}']"]
    @exists = !m_el.nil?
    @params = {}
    if @exists
      attribs = {}
      m_el.each_element('attrib') do |a_el|
        aname = a_el.attributes['name'].to_s
        atype = a_el.attributes['type'].to_s
        aalias = a_el.attributes['alias'].to_s
        attribs[aname] = { 'alias' => aalias, 'type' => atype }
      end
      @params[:attribs] = attribs
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
