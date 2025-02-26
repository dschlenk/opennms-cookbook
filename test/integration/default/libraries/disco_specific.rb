# frozen_string_literal: true
require 'rexml/document'
class DiscoSpecific < Inspec.resource(1)
  name 'disco_specific'

  desc '
    OpenNMS disco_specific
  '

  example '
    describe disco_specific(\'ipaddr\', \'Minneapolis\') do
      it { should exist }
      its(\'retry_count\') { should eq 37 }
      its(\'discovery_timeout\') { should eq 6000 }
      its(\'foreign_source\') { should eq \'disco-source\' }
    end
  '

  def initialize(ipaddr, location = nil)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/discovery-configuration.xml').content)
    xpath = if location.nil?
              "/discovery-configuration/specific[text() = '#{ipaddr}' and not(@location)]"
            else
              "/discovery-configuration/specific[text() = '#{ipaddr}' and @location = '#{location}']"
            end
    s_el = doc.elements[xpath]
    @exists = !s_el.nil?
    if @exists
      @params = {}
      @params[:retry_count] = s_el.attributes['retries'].nil? ? nil : s_el.attributes['retries'].to_i
      @params[:discovery_timeout] = s_el.attributes['timeout'].nil? ? nil : s_el.attributes['timeout'].to_i
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
