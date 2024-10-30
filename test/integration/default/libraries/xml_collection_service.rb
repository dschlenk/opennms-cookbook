require 'rexml/document'
class XmlCollectionService < Inspec.resource(1)
  name 'xml_collection_service'

  desc '
    OpenNMS xml_collection_service
  '

  example '
    describe xml_collection_service(\'XMLFoo\', \'foo\', \'foo\') do
      its(\'interval\') { should eq 400_000 }
      its(\'user_defined\') { should eq true }
      its(\'status\') { should eq \'off\' }
      its(\'collection_timeout\') { should eq 5000 }
      its(\'retry_count\') { should eq 10 }
      its(\'port\') { should eq 8181 }
      its(\'thresholding_enabled\') { should eq true }
    end
  '

  def initialize(service, collection, package)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/collectd-configuration.xml').content)
    s_el = doc.elements["/collectd-configuration/package[@name='#{package}']/service[@name='#{service}' and parameter[@key='collection' and @value='#{collection}']]"]
    @exists = !s_el.nil?
    @params = {}
    return unless @exists
    @params[:interval] = s_el.attributes['interval'].to_i
    unless s_el.attributes['user-defined'].nil?
      @params[:user_defined] = s_el.attributes['user-defined'].eql?('true')
    end
    unless s_el.attributes['status'].nil?
      @params[:status] = s_el.attributes['status']
    end
    unless s_el.elements["parameter[@key = 'timeout']/@value"].nil?
      tv = s_el.elements["parameter[@key = 'timeout']/@value"].value
      @params[:collection_timeout] = int_or_string(tv)
    end
    unless s_el.elements["parameter[@key = 'retry']/@value"].nil?
      rc = s_el.elements["parameter[@key = 'retry']/@value"].value
      @params[:retry_count] = int_or_string(rc)
    end
    unless s_el.elements["parameter[@key = 'port']/@value"].nil?
      p = s_el.elements["parameter[@key = 'port']/@value"].value
      @params[:port] = int_or_string(p)
    end
    unless s_el.elements["parameter[@key = 'thresholding-enabled']/@value"].nil?
      tev = s_el.elements["parameter[@key = 'thresholding-enabled']/@value"].value
      @params[:thresholding_enabled] = if tev.eql?('true')
                                         true
                                       elsif tev.eql?('false')
                                         false
                                       else
                                         tev
                                       end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  def bool_or_string(pv)
    if pv.eql?('true')
      true
    elsif pv.eql?('false')
      false
    else
      pv
    end
  end

  def int_or_string(pv)
    begin
      Integer(pv)
    rescue
      pv
    end
  end
end
