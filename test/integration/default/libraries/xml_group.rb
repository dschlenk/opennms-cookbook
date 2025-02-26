require 'rexml/document'
class XmlGroup < Inspec.resource(1)
  name 'xml_group'

  desc '
    OpenNMS xml_group
  '

  example '
    describe xml_group(\'fxa-sc\', \'http://{ipaddr}/group-example\', \'foo\') do
      it { should exist }
      its(\'resource_type\') { should eq \'dnsDns\' }
      its(\'key_xpath\') { should eq \'@measObjLdn\' }
      its(\'resource_xpath\') { should eq "/measCollecFile/measData/measInfo[@measInfoId=\'dns|dns\']/measValue" }
      its(\'resource_keys\') { should eq [\'/xpaths/xpath1\', \'/xpaths/xpath2\'] }
      its(\'timestamp_xpath\') { should eq \'/measCollecFile/fileFooter/measCollec/@endTime\' }
      its(\'timestamp_format\') { should eq "yyyy-MM-dd\'T\'HH:mm:ssZ" }
      its(\'objects\') { should eq \'nasdaq\' => { \'type\' => \'gauge\', \'xpath\' => "/blah/elmeentalaewflk[@attribute=\'avalue\']" } }
    end
  '

  def initialize(group_name, url, collection = 'default')
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/xml-datacollection-config.xml').content)
    grp = doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection}']/xml-source[@url='#{url}']/xml-group[@name='#{group_name}']"]
    @exists = !grp.nil?
    return unless @exists
    @params = {}
    @params[:resource_type] = grp.attributes['resource-type'].to_s
    @params[:key_xpath] = grp.attributes['key-xpath'].to_s unless grp.attributes['key-xpath'].nil?
    @params[:resource_xpath] = grp.attributes['resource-xpath'].to_s
    @params[:timestamp_xpath] = grp.attributes['timestamp-xpath'].to_s unless grp.attributes['timestamp-xpath'].nil?
    @params[:timestamp_format] = grp.attributes['timestamp-format'].to_s unless grp.attributes['timestamp-format'].nil?
    unless grp.elements['xml-object'].nil?
      @params[:objects] = {}
      grp.each_element('xml-object') do |f|
        @params[:objects][f.attributes['name'].to_s] = { 'type' => f.attributes['type'].to_s, 'xpath' => f.attributes['xpath'].to_s }
      end
    end
    unless grp.elements['resource-key'].nil?
      @params[:resource_keys] = []
      grp.each_element('resource-key/key-xpath') do |rk|
        @params[:resource_keys].push(rk.texts.collect(&:value).join('').strip)
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
