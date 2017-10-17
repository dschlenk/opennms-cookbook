# frozen_string_literal: true
require 'rexml/document'
class CollectionService < Inspec.resource(1)
  name 'collection_service'

  desc '
    OpenNMS collection_service
  '

  example '
    describe collection_service(\'SNMP\') do
      its(\'collection\') { should eq \'default\' }
      its(\'package_name\') { should eq \'example1\'}
      its(\'class_name\') { should eq \'org.opennms.netmgt.collectd.SnmpCollector\'}
      its(\'interval\') { should eq 300000 }
      its(\'user_defined\') { should eq false }
      its(\'status\') { should eq \'on\' }
      its(\'time_out\') { should eq 3000 }
      its(\'retry_count\') { should eq 1 }
      its(\'port\') { should eq 161 }
      its(\'thresholding_enabled\') { should eq true }
    end
  '

  def initialize(name, package_name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/collectd-configuration.xml').content)
    s_el = doc.elements["/collectd-configuration/package[@name = '#{package_name}']/service[@name = '#{name}']"]
    @params = {}
    @params[:collection] = s_el.elements["parameter[@key = 'collection']"].attributes['value']
    @params[:class_name] = doc.elements["/collectd-configuration/collector[@service = '#{name}']"].attributes['class-name']
    @params[:interval] = s_el.attributes['interval'].to_i
    @params[:user_defined] = false
    @params[:user_defined] = true if s_el.attributes['user-defined'] == 'true'
    @params[:status] = s_el.attributes['status']
    @params[:time_out] = s_el.elements["parameter[@key = 'timeout']"].attributes['value'].to_i unless s_el.elements["parameter[@key = 'timeout']"].nil?
    @params[:retry_count] = s_el.elements["parameter[@key = 'retry']"].attributes['value'].to_i unless s_el.elements["parameter[@key = 'retry']"].nil?
    @params[:port] = s_el.elements["parameter[@key = 'port']"].attributes['value'].to_i unless s_el.elements["parameter[@key = 'port']"].nil?
    @params[:thresholding_enabled] = false
    @params[:thresholding_enabled] = true unless s_el.elements["parameter[@key = 'thresholding-enabled']"].nil? || !(s_el.elements["parameter[@key = 'thresholding-enabled']"].attributes['value'] == 'true')
    @params[:params] = {}
    s_el.each_element('parameter') do |p|
      next if p.attributes['key'] == 'port'
      next if p.attributes['key'] == 'retry'
      next if p.attributes['key'] == 'collection'
      next if p.attributes['key'] == 'thresholding-enabled'
      next if p.attributes['key'] == 'timeout'
      @params[:params][p.attributes['key']] = p.attributes['value']
    end
  end

  def method_missing(param)
    @params[param]
  end
end
