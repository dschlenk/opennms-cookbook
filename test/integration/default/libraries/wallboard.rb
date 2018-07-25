# frozen_string_literal: true
require 'rexml/document'
class Wallboard < Inspec.resource(1)
  name 'wallboard'

  desc '
    OpenNMS wallboard
  '

  example '
    describe wallboard(\'board\') do
      it { should exist }
      it { should be_default }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/dashboard-config.xml').content)
    w_el = doc.elements["/wallboards/wallboard[@title = '#{name}']"]
    @exists = !w_el.nil?
    @default = false
    if @exists
      @default = true unless w_el.elements["default[contains(., 'true')]"].nil?
    end
  end

  def exist?
    @exists
  end

  def default?
    @default
  end
end
