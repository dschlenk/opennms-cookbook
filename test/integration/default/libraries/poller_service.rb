# frozen_string_literal: true
require 'rexml/document'
class PollerService < Inspec.resource(1)
  name 'poller_service'

  desc '
    OpenNMS poller_service
  '

  example '
    describe poller_service(\'SNMP\', \'foo\') do
      it { should exist }
      its(\'pattern\') { should eq \'^foobar$\' }
      its(\'interval\') { should eq 600_000 }
      its(\'user_defined\') { should eq true }
      its(\'status\') { should eq \'off\' }
      its(\'time_out\') { should eq 5000 }
      its(\'port\') { should eq 161 }
      its(\'parameters\') { should eq \'oid\' => { \'value\' =>  \'.1.3.6.1.2.1.1.2.0\' , \'configuration\' => \'<foo baz="true"/>\' } }
      its(\'class_name\') { should eq \'org.opennms.netmgt.poller.monitors.SnmpMonitor\' }
      its(\'class_parameters\') { should eq \'doomed\' => { \'value\' =>  \'true\' , \'configuration\' => \'<bar qux="false"/>\' } }
    end
  '

  def initialize(name, package_name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/poller-configuration.xml').content)
    s_el = doc.elements["/poller-configuration/package[@name = '#{package_name}']/service[@name = '#{name}']"]
    @exists = !s_el.nil?
    if @exists
      @params = {}
      @params[:class_name] = doc.elements["/poller-configuration/monitor[@service = '#{name}']"].attributes['class-name']
      @params[:interval] = s_el.attributes['interval'].to_i
      @params[:user_defined] = false
      @params[:user_defined] = true if s_el.attributes['user-defined'] == 'true'
      @params[:status] = s_el.attributes['status']
      @params[:time_out] = s_el.elements["parameter[@key = 'timeout']"].attributes['value'].to_i unless s_el.elements["parameter[@key = 'timeout']"].nil?
      @params[:port] = s_el.elements["parameter[@key = 'port']"].attributes['value'].to_i unless s_el.elements["parameter[@key = 'port']"].nil?
      @params[:pattern] = s_el.elements['pattern'].texts.collect(&:value).join('').strip unless s_el.elements['pattern'].nil?
      @params[:parameters] = {}
      s_el.each_element('parameter') do |p|
        next if p.attributes['key'] == 'port'
        next if p.attributes['key'] == 'timeout'
        @params[:parameters][p.attributes['key']] = {}
        @params[:parameters][p.attributes['key']]['value'] = p.attributes['value'] unless p.attributes['value'].nil?
        @params[:parameters][p.attributes['key']]['configuration'] = p.elements[1].to_s unless p.elements[1].nil?
      end
      @params[:class_parameters] = {}
      s_el.each_element("/poller-configuration/monitor[@service = '#{name}']/parameter") do |p|
        @params[:class_parameters][p.attributes['key']] = {}
        @params[:class_parameters][p.attributes['key']]['value'] = p.attributes['value'] unless p.attributes['value'].nil?
        @params[:class_parameters][p.attributes['key']]['configuration'] = p.elements[1].to_s unless p.elements[1].nil?
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
