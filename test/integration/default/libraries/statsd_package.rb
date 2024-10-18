# frozen_string_literal: true
require 'rexml/document'
class StatsdPackage < Inspec.resource(1)
  name 'statsd_package'

  desc '
    OpenNMS statsd_package
  '

  example '
    describe statsd_package(\'cheftest\') do
      it { should exist }
      its(\'filter\') { should eq "IPADDR != \'0.0.0.0\'" }
    end
  '

  def initialize(name)
    @name = name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/statsd-configuration.xml').content)
    p_el = doc.elements["/statistics-daemon-configuration/package[@name='#{name}']"]
    @exists = !p_el.nil?
    if @exists
      @params = {}
      @params[:filter] = p_el.elements['filter'].texts.collect(&:value).join('') unless p_el.elements['filter'].nil?
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
