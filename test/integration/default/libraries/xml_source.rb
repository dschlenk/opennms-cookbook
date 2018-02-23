# frozen_string_literal: true
require 'rexml/document'
class XmlSource < Inspec.resource(1)
  name 'xml_source'

  desc '
    OpenNMS xml_source
  '

  example '
    describe xml_source(\'http://{ipaddr}/group-example\', \'foo\') do
      it { should exist }
      its(\'request_method\') { should eq \'GET\' }
      its(\'request_params\') { should eq \'timeout\' => 6000, \'retries\' => 2 }
      its(\'request_headers\') { should eq \'User-Agent\' => \'HotJava/1.1.2 FCS\' }
      its(\'request_content\') { should eq "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>" }
      its(\'import_groups\') { should eq [\'mygroups.xml\'] }
    end
  '

  def initialize(url, collection = 'default')
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/xml-datacollection-config.xml').content)
    src = doc.elements["/xml-datacollection-config/xml-collection[@name='#{collection}']/xml-source[@url='#{url}']"]
    @exists = !src.nil?
    return unless @exists
    @params = {}
    @params[:request_method] = src.elements['request'].attributes['method'].to_s unless src.elements['request'].nil? || src.elements['request'].attributes['method'].nil?
    unless src.elements['request/parameter'].nil?
      @params[:request_params] = {}
      src.each_element('request/parameter') do |rp|
        @params[:request_params][rp.attributes['name'].to_s] = rp.attributes['value'].to_s
      end
    end
    unless src.elements['request/header'].nil?
      @params[:request_headers] = {}
      src.each_element('request/header') do |rp|
        @params[:request_headers][rp.attributes['name'].to_s] = rp.attributes['value'].to_s
      end
    end
    @params[:request_content] = src.elements['request/content'].texts.join('\n') unless src.elements['request/content'].nil?
    unless src.elements['import-groups'].nil?
      @params[:import_groups] = []
      src.each_element('import-groups') do |f|
        fn = f.texts.join('').gsub(%r{xml-datacollection/}, '')
        @params[:import_groups].push fn
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
