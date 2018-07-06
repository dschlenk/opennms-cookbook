# frozen_string_literal: true
require 'rexml/document'
class PollOutage < Inspec.resource(1)
  name 'poll_outage'

  desc '
    OpenNMS poll_outage
  '

  example '
    describe poll_outage(\'foo\') do
      it { should exist }
      its(\'times\') { should eq \'id\' => { \'day\' \'begins\' => \'00:00:00\', \'ends\' => \'01:01:01\'} }
      its(\'type\') { should eq \'weekly\' }
      its(\'interfaces\') { should eq [\'127.0.0.1\'] }
      its(\'nodes\') { should eq [1, 2, 3] }
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/poll-outages.xml').content)
    o_el = doc.elements["/outages/outage[@name = '#{@name}']"]
    @exists = !o_el.nil?
    if @exists
      @params = {}
      @params[:type] = o_el.attributes['type'].to_s
      @params[:times] = {}
      o_el.each_element('time') do |time|
        @params[:times][time.attributes['id']]['day'] = time.attributes['day'].to_s unless time.attributes['day'].nil?
        @params[:times][time.attributes['id']]['begins'] = time.attributes['begins'].to_s
        @params[:times][time.attributes['id']]['ends'] = time.attributes['ends'].to_s
      end
      @params[:interfaces] = []
      o_el.each_element('interfaces') do |iface|
        @params[:interfaces].push iface.attributes['address']
      end
      @params[:nodes] = []
      o_el.each_element('node') do |n|
        @params[:nodes].push n.attributes['id']
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
