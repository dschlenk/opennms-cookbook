# frozen_string_literal: true
require 'rexml/document'
class ThreshdPackage < Inspec.resource(1)
  name 'threshd_package'

  desc '
    OpenNMS threshd_package
  '

  example '
    describe threshd_package(\'cheftest\') do
      it { should exist }
      its(\'filter\') { should eq "IPADDR != \'0.0.0.0\'" }
      its(\'specifics\') { should eq [\'172.17.16.1\'] }
      its(\'include_ranges\') { should eq [{ \'begin\' => \'172.17.13.1\', \'end\' => \'172.17.13.254\' }, { \'begin\' => \'172.17.20.1\', \'end\' => \'172.17.20.254\' }] }
      its(\'exclude_ranges\') { should eq [{ \'begin\' => \'10.0.0.1\', \'end\' => \'10.254.254.254\' }] }
      its(\'include_urls\') { should eq [\'file:/opt/opennms/etc/include\'] }
      its(\'services\') { should eq [{ \'name\' => \'ICMP\', \'interval\' => 300_000, \'status\' => \'on\', \'params\' => { \'thresholding-group\' => \'cheftest\' } }] }
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/threshd-configuration.xml').content)
    p_el = doc.elements["/threshd-configuration/package[@name='#{name}']"]
    @exists = !p_el.nil?
    return unless @exists
    @params = {}
    @params[:filter] = p_el.elements['filter'].text.to_s
    @params[:include_ranges] = []
    p_el.each_element('include-range') do |ir|
      @params[:include_ranges].push 'begin' => ir.attributes['begin'].to_s, 'end' => ir.attributes['end'].to_s
    end
    @params[:exclude_ranges] = []
    p_el.each_element('exclude-range') do |er|
      @params[:exclude_ranges].push 'begin' => er.attributes['begin'].to_s, 'end' => er.attributes['end'].to_s
    end
    @params[:specifics] = []
    p_el.each_element('specific') do |s|
      @params[:specifics].push s.text.to_s
    end
    @params[:include_urls] = []
    p_el.each_element('include-url') do |iu|
      @params[:include_urls].push iu.text.to_s
    end
    unless p_el.elements['service'].nil?
      @params[:services] = []
      p_el.each_element('service') do |s|
        interval = s.attributes['interval'].to_i
        ud = nil
        unless s.attributes['user-defined'].nil?
          ud = false
          ud = true unless s.attributes['user-defined'].nil? || !(s.attributes['user-defined'].to_s == 'true')
        end
        status = nil
        status = s.attributes['status'].to_s unless s.attributes['status'].nil?
        params = nil
        unless s.elements['parameter'].nil?
          params = {}
          s.each_element('parameter') do |p|
            params[p.attributes['key'].to_s] = p.attributes['value'].to_s
          end
        end
        h = {}
        h['name'] = s.attributes['name'].to_s
        h['interval'] = interval
        h['user-defined'] = ud unless ud.nil?
        h['status'] = status unless status.nil?
        h['params'] = params unless params.nil?
        @params[:services].push h
      end
    end
    unless p_el.elements['outage-calendar'].nil?
      @params[:outage_calendars] = []
      p_el.each_element('outage-calendar') do |o|
        @params[:outage_calendars].push o.texts.collect(&:value).join('')
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
