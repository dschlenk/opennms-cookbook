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
    doc = REXML::Document.new(inspec.http("http://localhost:8980/opennms/rest/events?eventUei=#{uei}&orderBy=id&order=desc&limit=1", auth: { user: 'admin', pass: 'admin' }).body)
    s_el = doc.elements['/events/event']
    @exists = !s_el.nil?
    if @exists
      @params = {}
      @params[:parameters] = []
      if s_el.elements['parameters/parameter'].nil?
        # 16
        unless s_el.elements['parms'].nil?
          parmstr = s_el.elements['parms'].texts.collect(&:value).join('')
          parms = parmstr.split(';')
          parms.each do |p|
            key, value = p.split('=')
            value = value[0, value.rindex('(')]
            @params[:parameters].push key + ' ' + value
          end
          # else dunno!
        end
      else
        # 17+
        s_el.each_element('parameters/parameter') do |p|
          @params[:parameters].push p.attributes['name'].to_s + ' ' + p.attributes['value'].to_s
        end
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
