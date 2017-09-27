# frozen_string_literal: true
require 'rexml/document'
class OpennmsGroup < Inspec.resource(1)
  name 'opennms_group'

  desc '
    OpenNMS group
  '

  example '
    describe opennms_group(\'nerds\') do
      it { should exist }
      its(\'users\') { should eq [\'admin\'] }
      its(\'duty_schedules\') { should eq [\'MoTuWeThFrSaSu800-1700\'] }
      its(\'comments\') { should eq \'pocket protectors and such\' }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/groups.xml').content)
    g_el = doc.elements["/groupinfo/groups/group[name/text() = '#{name}']"]
    puts g_el
    @exists = !g_el.nil?
    @params = {}
    if @exists
      users = []
      g_el.each_element('user') do |u|
        users.push u.text()
      end
      @params[:users] = users unless users.length == 0
      dsched = []
      g_el.each_element('duty-schedule') do |ds|
        dsched.push ds.text()
      end
      @params[:duty_schedules] = dsched unless dsched.length == 0
      @params[:comments] = g_el.elements["comments"].text() unless g_el.elements["comments"].nil?
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
