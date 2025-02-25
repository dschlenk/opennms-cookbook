# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ImportNodeInterface < Inspec.resource(1)
  name 'import_node_interface'

  desc '
    OpenNMS import_node_interfacee
  '

  example '
    describe import_node_interface(\'ip_addr\', \'foreign_source_name\', \'foreign_id\', 1242) do
      it { should exist }
      its(\'managed\') { should be true }
      its(\'snmp_primary\') { should eq \'P\' }
      its(\'categories\') { should eq %w(Servers Test) }
      its(\'meta_data\') { should eq([{ \'context\' => \'foo\', \'key\' => \'bar\', \'value\' => \'baz\'}, { \'context\' => \'foofoo\', \'key\' => \'barbar\', \'value\' => \'bazbaz\' }])}
    end
  '

  def initialize(ip_addr, foreign_source_name, foreign_id, port=8980)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:#{port}/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}").normalize.to_str
    begin
      interface = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    doc = REXML::Document.new(interface)
    i_el = doc.elements['/interface']
    @exists = !i_el.nil?
    if @exists
      @params = {}
      @params[:managed] = true
      @params[:managed] = false if i_el.attributes['managed'] == 'false'
      @params[:snmp_primary] = i_el.attributes['snmp-primary'] unless i_el.attributes['snmp-primary'].nil?
      @categories = []
      i_el.each_element('category') do |c_el|
        @categories.push c_el.attributes['name']
      end
      meta_datas = []
      i_el.each_element('meta-data') do |a_el|
        meta_data = {}
        meta_data['context'] = a_el['context']
        meta_data['key'] =  a_el['key']
        meta_data['value'] =  a_el['value']
        meta_datas.push meta_data
      end
      @meta_data = meta_datas
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
  attr_reader :categories
  attr_reader :meta_data
end
