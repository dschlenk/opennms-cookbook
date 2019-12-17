# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ServiceDetector < Inspec.resource(1)
  name 'service_detector'

  desc '
    OpenNMS service_detector
  '

  example '
    describe service_detector(\'Router\', \'another-source\') do
      its(\'class_name\') { should eq \'org.opennms.netmgt.provision.detector.snmp.SnmpDetector\' }
      its(\'port\') { should eq 161 }
      its(\'retry_count\') { should eq 3 }
      its(\'time_out\') { should eq 5000 }
      its(\'parameters\') { should eq \'vbname\' => \'.1.3.6.1.2.1.4.1.0\', \'vbvalue\' => \'1\' }
    end
  '

  def initialize(name, foreign_source)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:8980/opennms/rest/foreignSources/#{foreign_source}/detectors/#{name}").normalize.to_str
    begin
      fs = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    @exists = true
    puts "fs: '#{fs}'"
    if fs.empty?
      @exists = false
      return
    end
    doc = REXML::Document.new(fs)
    @params = {}
    @params[:class_name] = doc.elements['/detector'].attributes['class'].to_s
    @params[:port] = doc.elements["/detector/parameter[@key = 'port']"].attributes['value'].to_i unless doc.elements["/detector/parameter[@key = 'port']"].nil?
    @params[:retry_count] = doc.elements["/detector/parameter[@key = 'retries']"].attributes['value'].to_i unless doc.elements["/detector/parameter[@key = 'retries']"].nil?
    @params[:time_out] = doc.elements["/detector/parameter[@key = 'timeout']"].attributes['value'].to_i unless doc.elements["/detector/parameter[@key = 'timeout']"].nil?
    @params[:parameters] = {}
    doc.each_element('detector/parameter') do |p|
      next if %w(port retries timeout).include?(p.attributes['key'])
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
