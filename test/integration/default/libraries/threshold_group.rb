# frozen_string_literal: true
require 'rexml/document'
class ThresholdGroup < Inspec.resource(1)
  name 'threshold_group'

  desc '
    OpenNMS threshold_group
  '

  example '
    describe threshold_group(\'cheftest\') do
      it { should exist }
      its(\'rrd_repository\') { should eq \'/opt/opennms/share/rrd/response\' }
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/thresholds.xml').content)
    g_el = doc.elements["/thresholding-config/group[@name='#{name}']"]
    @exists = !g_el.nil?
    return unless @exists
    @params = {}
    @params[:rrd_repository] = g_el.attributes['rrdRepository'].to_s
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
