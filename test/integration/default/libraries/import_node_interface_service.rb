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
    end
  '

  def initialize(service, ip_addr, foreign_source_name, foreign_id, port=8980)
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
      @params = {}
      s_el.each_element('category') do |c_el|
        categories.push c_el.attributes['name']
      end
      @params[:categories] = categories
      assets = {}
      s_el.each_element('asset') do |a_el|
        assets[a_el.attributes['name']] = a_el.attributes['value']
      end
      @params[:assets] = assets
      meta_data = {}
      meta_datas = []
      @params = {}
      s_el.each_element('meta-data') do |a_el|
        meta_data['context'] = a_el['context']
        meta_data['key'] =  a_el['key']
        meta_data['value'] =  a_el['value']
        meta_datas.push meta_data
      end
      @params[:meta_data] = meta_datas
    end
  end

  def exist?
    @exists
  end
end
