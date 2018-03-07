# frozen_string_literal: true
require 'rexml/document'
class SurveillanceView < Inspec.resource(1)
  name 'surveillance_view'

  desc '
    OpenNMS surveillance_view
  '

  example '
    describe surveillance_view(\'default\') do
      rows \'Routers\' => [\'Routers\'], \'Servers\' => [\'Servers\']
      columns \'PROD\' => [\'Production\'], \'TEST\' => %w(Test Development)
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/surveillance-views.xml').content)
    svel = doc.elements["/surveillance-view-configuration/views/view[@name='#{name}']"]
    @exists = !svel.nil?
    return unless @exists
    @params = {}
    unless svel.elements['rows'].nil?
      @params[:rows] = {}
      svel.each_element('rows/row-def') do |rd|
        label = rd.attributes['label'].to_s
        cats = []
        rd.each_element('category') do |cat|
          cats.push cat.attributes['name'].to_s
        end
        @params[:rows][label] = cats
      end
    end
    unless svel.elements['columns'].nil?
      @params[:columns] = {}
      svel.each_element('columns/column-def') do |cd|
        label = cd.attributes['label'].to_s
        cats = []
        cd.each_element('category') do |cat|
          cats.push cat.attributes['name'].to_s
        end
        @params[:columns][label] = cats
      end
    end
    @params[:default_view] = false
    @params[:default_view] = true if doc.elements['/surveillance-view-configuration'].attributes['default-view'].to_s == name
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
