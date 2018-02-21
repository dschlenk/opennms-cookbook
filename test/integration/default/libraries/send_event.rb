# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class SendEvent < Inspec.resource(1)
  name 'send_event'

  desc '
    OpenNMS send_event
  '

  example '
    describe send_event(\'uei.opennms.org/internal/reloadDaemonConfig\') do
      it { should exist }
      its(\'parameters\') { should eq [\'daemonName Threshd\', \'configFile thresholds.xml\'] }
    end
  '

  def initialize(uei)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:8980/opennms/rest/events?eventUei=#{uei}&orderBy=id&order=desc&limit=1").normalize.to_str
    begin
      e = RestClient.get(parsed_url)
    rescue StandardError => ee
      puts ee
      @exists = false
      return
    end
    doc = REXML::Document.new(e)
    s_el = doc.elements['/events/event']
    @exists = !s_el.nil?
    if @exists
      @params = {}
      @params[:parameters] = []
      s_el.each_element('parameters/parameter') do |p|
        @params[:parameters].push p.attributes['name'].to_s + ' ' + p.attributes['value'].to_s
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
