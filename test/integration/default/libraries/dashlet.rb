# frozen_string_literal: true
require 'rexml/document'
class Dashlet < Inspec.resource(1)
  name 'dashlet'

  desc '
    OpenNMS dashlet
  '

  example '
    describe dashlet(\'All Categories\', \'Default Wallboard\') do
      it { should exist }
      its(\'dashlet_name\') { should eq \'Surveillance\' }
      its(\'boost_duration\') { should eq 0 }
      its(\'boost_priority\') { should eq 0 }
      its(\'priority\') { should eq 5 }
      its(\'duration\') { should eq 15 }
      its(\'parameters\') { should eq \'viewName\' => \'default\' }
    end
  '

  def initialize(dashlet_title, wallboard_title)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/dashboard-config.xml').content)
    d_el = doc.elements["/wallboards/wallboard[@title = '#{wallboard_title}']/dashlets/dashlet[title[contains(., '#{dashlet_title}')]]"]
    @exists = !d_el.nil?
    @params = {}
    if @exists
      @params[:dashlet_name] = d_el.elements['dashletName'].text.to_s unless d_el.elements['dashletName'].nil?
      @params[:boost_duration] = d_el.elements['boostDuration'].text.to_i unless d_el.elements['boostDuration'].nil?
      @params[:boost_priority] = d_el.elements['boostPriority'].text.to_i unless d_el.elements['boostPriority'].nil?
      @params[:duration] = d_el.elements['duration'].text.to_i unless d_el.elements['duration'].nil?
      @params[:priority] = d_el.elements['priority'].text.to_i unless d_el.elements['priority'].nil?
      @params[:parameters] = {}
      d_el.each_element('parameters/entry') do |e|
        @params[:parameters][e.elements['key'].text.to_s] = e.elements['value'].text.to_s
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
