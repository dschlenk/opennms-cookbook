# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class RoleSchedule < Inspec.resource(1)
  name 'role_schedule'

  desc '
    OpenNMS role_schedule
  '

  example '
    describe role_schedule(\'specific\', \'chefrole\', \'admin\') do
      it { should exist }
      its(\'times\') { should eq [{ \'begins\' => \'20-Mar-2014 00:00:00\', \'ends\' => \'20-Mar-2014 11:00:00\' }, { \'begins\' => \'21-Mar-2014 15:00:00\', \'ends\' => \'21-Mar-2014 23:00:00\' }] }
    end
  '

  def initialize(type, role, user)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/groups.xml').content)
    s_el = doc.elements["/groupinfo/roles/role[@name = '#{role}']/schedule[@name = '#{user}' and @type = '#{type}']"]
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    @params[:times] = []
    s_el.each_element('time') do |t|
      begins = t.attributes['begins'].to_s
      ends = t.attributes['ends'].to_s
      day = t.attributes['day'].to_s unless t.attributes['day'].nil?
      h = { 'begins' => begins, 'ends' => ends }
      h['day'] = day unless day.nil?
      @params[:times].push h
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
