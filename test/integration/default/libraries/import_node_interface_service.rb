# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ImportNodeInterfaceService < Inspec.resource(1)
  name 'import_node_interface_service'

  desc '
    OpenNMS import_node_interface_service
  '

  example '
    describe import_node_interface_service(\'service\', \'ip_addr\', \'foreign_source_name\', \'foreign_id\', 1243) do
      it { should exist }
      its(\'categories\') { should eq %w(Servers Test) }
      its(\'meta_data\') { should eq([{ \'context\' => \'foo\', \'key\' => \'bar\', \'value\' => \'baz\'}, { \'context\' => \'foofoo\', \'key\' => \'barbar\', \'value\' => \'bazbaz\' }])}
    end
  '

  def initialize(service, ip_addr, foreign_source_name, foreign_id, port = 8980)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:#{port}/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}/services/#{service}").normalize.to_str
    begin
      service = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    doc = REXML::Document.new(service)
    s_el = doc.elements['/monitored-service']
    @exists = !s_el.nil?
    if @exists
      @categories = []
      s_el.each_element('category') do |c_el|
        @categories.push c_el.attributes['name']
      end
      meta_datas = []
      s_el.each_element('meta-data') do |a_el|
        meta_data = {}
        meta_data['context'] = a_el['context']
        meta_data['key'] = a_el['key']
        meta_data['value'] =  a_el['value']
        meta_datas.push meta_data
      end
      @meta_data = meta_datas
    end
  end

  def exist?
    @exists
  end
  attr_reader :categories
  attr_reader :meta_data
end
