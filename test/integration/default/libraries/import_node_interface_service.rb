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
  end

  def exist?
    @exists
  end
end
