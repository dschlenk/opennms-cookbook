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
    describe role_schedule(\'specific\', \'chefrole\', \'admin\', [{ \'begins\' => \'20-Mar-2014 00:00:00\' }]) do
      it { should exist }
    end
  '

  def initialize(type, role, user, times)
    @exists = false
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/groups.xml').content)
    schedule = doc.elements["/groupinfo/roles/role[@name = '#{role}']/schedule[@name = '#{user}' and @type = '#{type}']"]
    return if schedule.nil?
    doc.root.each_element("/groupinfo/roles/role[@name = '#{role}']/schedule[@name = '#{user}' and @type = '#{type}']") do |s_el|
      t = []
      s_el.each_element('time') do |time|
        begins = time.attributes['begins']
        ends = time.attributes['ends']
        day = time.attributes['day']
        h = { 'begins' => begins, 'ends' => ends, 'day' => day }.compact
        t.push h
      end
      @exists = true if !times.difference(t).any? && !t.difference(times).any?
    end
  end

  def exist?
    @exists
  end
end
