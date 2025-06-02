require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ServiceDetector < Inspec.resource(1)
  name 'service_detector'

  desc '
    OpenNMS service_detector
  '

  example '
    describe service_detector(\'Router\', \'another-source\', 1238) do
      its(\'class_name\') { should eq \'org.opennms.netmgt.provision.detector.snmp.SnmpDetector\' }
      its(\'parameters\') { should eq \'vbname\' => \'.1.3.6.1.2.1.4.1.0\', \'vbvalue\' => \'1\' }
    end
  '

  def initialize(name, foreign_source, port = 8980)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:#{port}/opennms/rest/foreignSources/#{foreign_source}/detectors/#{name}").normalize.to_str
    begin
      fs = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    @exists = true
    if fs.empty?
      @exists = false
      return
    end
    doc = REXML::Document.new(fs)
    @params = {}
    @params[:class_name] = doc.elements['/detector'].attributes['class'].to_s
    @params[:parameters] = {}
    doc.each_element('detector/parameter') do |p|
      @params[:parameters][p.attributes['key'].to_s] = p.attributes['value'].to_s
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
