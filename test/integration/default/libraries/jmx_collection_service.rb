# frozen_string_literal: true
require 'rexml/document'
class JmxCollectionService < Inspec.resource(1)
  name 'jmx_collection_service'

  desc '
    OpenNMS jmx_collection_service
  '

  example '
    describe jmx_collection_service(\'jmx\', \'jmxcollection\', \'jmx1\') do
      it { should exist }
      its(\'ds_name\') { should eq \'jmx-ds-name\' }
      its(\'friendly_name\') { should eq \'jmx-friendly-name\' }
      its(\'interval\') { should eq 300000 }
      its(\'user_defined\') { should eq false }
      its(\'status\') { should eq \'on\' }
      its(\'collection_timeout\') { should eq 3000 }
      its(\'retry_count\') { should eq 1 }
      its(\'thresholding_enabled\') { should eq false }
      its(\'port\') { should eq 1099 }
      its(\'protocol\') { should eq \'rmi\' }
      its(\'url_path\') { should eq \'/jmxrmi\' }
      its(\'rrd_base_name\') { should eq \'java\' }
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
      @params[:protocol] = s_el.elements["parameter[@key = 'protocol']/@value"].to_s
      @params[:url_path] = s_el.elements["parameter[@key = 'urlPath']/@value"].to_s
      @params[:rrd_base_name] = s_el.elements["parameter[@key = 'rrd-base-name']/@value"].to_s
      @params[:ds_name] = s_el.elements["parameter[@key = 'ds-name']/@value"].to_s
      @params[:friendly_name] = s_el.elements["parameter[@key = 'friendly-name']/@value"].to_s
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
