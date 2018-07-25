# frozen_string_literal: true
require 'rexml/document'
class DiscoSpecific < Inspec.resource(1)
  name 'disco_specific'

  desc '
    OpenNMS disco_specific
  '

  example '
    describe disco_specific(\'ipaddr\') do
      it { should exist }
      its(\'retry_count\') { should eq 37 }
      its(\'discovery_timeout\') { should eq 6000 }
      its(\'location\') { should eq \'Detroit\' }
      its(\'foreign_source\') { should eq \'disco-source\' }
    end
  '

  def initialize(ipaddr)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/discovery-configuration.xml').content)
    xpath = "/discovery-configuration/specific[text() = '#{ipaddr}']"
    s_el = doc.elements[xpath]
    @exists = !s_el.nil?
    if @exists
      @params = {}
      @params[:retry_count] = s_el.attributes['retries'].to_i
      @params[:discovery_timeout] = s_el.attributes['timeout'].to_i
      @params[:location] = s_el.attributes['location']
      @params[:foreign_source] = s_el.attributes['foreign-source']
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
