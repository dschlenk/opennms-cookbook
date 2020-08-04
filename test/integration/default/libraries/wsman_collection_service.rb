# frozen_string_literal: true
require 'rexml/document'
class WsManCollectionService < Inspec.resource(1)
  name 'wsman_collection_service'

  desc '
    OpenNMS wsman_collection_service
  '

  example '
    describe wsman_collection_service(\'Ws-ManFoo\', \'foo\', \'foo\') do
      it { should exist }
      its(\'interval\') { should eq 400_000 }
      its(\'user_defined\') { should eq true }
      its(\'status\') { should eq \'off\' }
      its(\'collection_timeout\') { should eq 5000 }
      its(\'retry_count\') { should eq 10 }
      its(\'port\') { should eq 4445 }
      its(\'thresholding_enabled\') { should eq true }
    end
  '

  def initialize(service, collection, package)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/collectd-configuration.xml').content)
    s_el = doc.elements["/collectd-configuration/package[@name='#{package}']/service[@name='#{service}' and parameter[@key='collection' and @value='#{collection}']]"]
    @exists = !s_el.nil?
    @params = {}
    if @exists
      @params[:interval] = s_el.attributes['interval'].to_i
      @params[:user_defined] = false
      @params[:user_defined] = true if s_el.attributes['user-defined'].to_s == 'true'
      @params[:status] = s_el.attributes['status'].to_s
      @params[:collection_timeout] = s_el.elements["parameter[@key = 'timeout']/@value"].to_s.to_i
      @params[:retry_count] = s_el.elements["parameter[@key = 'retry']/@value"].to_s.to_i
      @params[:port] = s_el.elements["parameter[@key = 'port']/@value"].to_s.to_i
      @params[:thresholding_enabled] = false
      @params[:thresholding_enabled] = true if s_el.elements["parameter[@key = 'thresholding-enabled']/@value"].to_s == 'true'
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
