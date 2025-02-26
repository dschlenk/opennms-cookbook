# frozen_string_literal: true
require 'rexml/document'
class PollerPackage < Inspec.resource(1)
  name 'poller_package'

  desc '
    OpenNMS poller_package
  '

  example '
    describe poller_package(\'foo\') do
      it { should exist }
      its(\'filter\') { should eq "(IPADDR != \'0.0.0.0\') & (categoryName == \'foo\')" }
      its(\'specifics\') { should eq [\'10.0.0.1\'] }
      its(\'include_ranges\') { should eq [{ \'begin\' => \'10.0.1.1\', \'end\' => \'10.0.1.254\' }] }
      its(\'exclude_ranges\') { should eq [{ \'begin\' => \'10.0.2.1\', \'end\' => \'10.0.2.254\' }] }
      its(\'include_urls\') { should eq [\'file:/opt/opennms/etc/foo\'] }
      its(\'remote\') { should eq true }
      its(\'outage_calendars\') { should eq [\'ignore localhost on mondays\'] }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/poller-configuration.xml').content)
    p_el = doc.elements["/poller-configuration/package[@name = '#{@name}']"]
    @exists = !p_el.nil?
    if @exists
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
      @params[:rrd_step] = p_el.elements['rrd'].attributes['step'].to_i
      @params[:rras] = []
      p_el.each_element('rrd/rra') do |rra|
        @params[:rras].push rra.texts.collect(&:value).join("\n")
      end
      @params[:remote] = false
      @params[:remote] = true if p_el.attributes['remote'].to_s == 'true'
      unless p_el.elements['outage-calendar'].nil?
        @params[:outage_calendars] = []
        p_el.each_element('outage-calendar') do |oc|
          @params[:outage_calendars].push oc.texts.collect(&:value).join("\n")
        end
      end
      @params[:downtimes] = {}
      p_el.each_element('downtime') do |dt|
        b = dt.attributes['begin'].to_s
        i = dt.attributes['interval'].to_s unless dt.attributes['interval'].nil?
        e = dt.attributes['end'].to_s
        d = dt.attributes['delete'].to_s unless dt.attributes['delete'].nil?
        @params[:downtimes][b] = {}
        @params[:downtimes][b]['end'] = e
        @params[:downtimes][b]['interval'] = i unless i.nil?
        @params[:downtimes][b]['delete'] = d unless d.nil?
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
