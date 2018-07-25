# frozen_string_literal: true
require 'rexml/document'
class DiscoUrl < Inspec.resource(1)
  name 'disco_url'

  desc '
    OpenNMS disco_url
  '

  example '
    describe disco_url(\'http://example.com/include\') do
      it { should exist }
      its(\'file_name\') { should eq \'include\' }
      its(\'retry_count\') { should eq 13 }
      its(\'discovery_timeout\') { should eq 4000 }
    end
  '

  def initialize(url)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/discovery-configuration.xml').content)
    xpath = "/discovery-configuration/include-url[text() = '#{url}']"
    u_el = doc.elements[xpath]
    @exists = !u_el.nil?
    if @exists
      @params = {}
      if url =~ /^file:(.*$)/
        file_name = Regexp.last_match(1)
        @params[:file_name] = file_name if inspec.file(file_name).exist?
      end
      @params[:retry_count] = u_el.attributes['retries'].to_i unless u_el.attributes['retries'].nil?
      @params[:discovery_timeout] = u_el.attributes['timeout'].to_i unless u_el.attributes['timeout'].nil?
      @params[:location] = u_el.attributes['location']
      @params[:foreign_source] = u_el.attributes['foreign-source']
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
