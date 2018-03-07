# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class OnmsGroup < Inspec.resource(1)
  name 'onms_group'

  desc '
    OpenNMS onms_group
  '

  example '
    describe onms_group(\'rolegroup\') do
      it { should exist }
      its(\'comments\') { should eq \'pocket protectors and such\' }
      its(\'users\') { should eq [\'admin\'] }
      its(\'duty_schedules\') { should eq [\'MoTuWeThFrSaSu800-1700\'] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/groups.xml').content)
    g_el = doc.elements["/groupinfo/groups/group[name[text() = '#{name}']]"]
    @exists = !g_el.nil?
    return unless @exists
    @params = {}
    @params[:default_svg_map] = g_el.elements['default-map'].texts.join('\n') unless g_el.elements['default-map'].nil?
    @params[:comments] = g_el.elements['comments'].texts.join('\n') unless g_el.elements['comments'].nil?
    unless g_el.elements['user'].nil?
      @params[:users] = []
      g_el.each_element('user') do |u|
        @params[:users].push u.text
      end
    end
    unless g_el.elements['duty-schedule'].nil?
      @params[:duty_schedules] = []
      g_el.each_element('duty-schedule') do |s|
        @params[:duty_schedules].push s.text
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
