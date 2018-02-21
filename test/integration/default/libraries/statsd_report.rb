# frozen_string_literal: true
require 'rexml/document'
class StatsdReport < Inspec.resource(1)
  name 'statsd_report'

  desc '
    OpenNMS statsd_report
  '

  example '
  describe statsd_report(\'chefReport\', \'cheftest\') do
    it { should exist }
    its(\'report_name\') { should eq \'chefReport\' }
    its(\'description\') { should eq \'testing report lwrp\' }
    its(\'schedule\') { should eq \'0 30 2 * * ?\' }
    its(\'retain_interval\') { should eq 5_184_000_000 }
    its(\'status\') { should eq \'off\' }
    its(\'parameters\') { should eq \'count\' => \'20\', \'consolidationFunction\' => \'AVERAGE\', \'relativeTime\' => \'YESTERDAY\', \'resourceTypeMatch\' => \'interfaceSnmp\', \'attributeMatch\' => \'ifOutOctets\' }
    its(\'class_name\') { should eq \'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor\' }
  end

  '

  def initialize(name, package)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/statsd-configuration.xml').content)
    r_el = doc.elements["/statistics-daemon-configuration/package[@name='#{package}']/packageReport[@name='#{name}']"]
    @exists = !r_el.nil?
    return unless @exists
    @params = {}
    @params[:description] = r_el.attributes['description'].to_s
    @params[:schedule] = r_el.attributes['schedule'].to_s
    @params[:retain_interval] = r_el.attributes['retainInterval'].to_i
    @params[:status] = r_el.attributes['status'].to_s
    unless r_el.elements['parameter'].nil?
      @params[:parameters] = {}
      r_el.each_element('parameter') do |p|
        @params[:parameters][p.attributes['key'].to_s] = p.attributes['value'].to_s
      end
    end
    @params[:class_name] = doc.elements["/statistics-daemon-configuration/report[@name='#{name}']"].attributes['class-name'].to_s
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
