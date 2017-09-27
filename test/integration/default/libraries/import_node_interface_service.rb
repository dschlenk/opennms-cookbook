# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
class ImportNodeInterfaceService < Inspec.resource(1)
  name 'import_node_interface_service'

  desc '
    OpenNMS import_node_interface_service
  '

  example '
    describe import_node_interface_service(\'service\', \'ip_addr\', \'foreign_source_name\', \'foreign_id\') do
      it { should exist }
    end
  '

  def initialize(service, ip_addr, foreign_source_name, foreign_id)
    begin
      service = RestClient.get("http://admin:admin@localhost:8980/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}/services/#{service}")
      doc = REXML::Document.new(service)
      s_el = doc.elements["/monitored-service"]
    rescue Exception => e
      puts "oh dam #{e}"
    end
    @exists = !s_el.nil?
  end

  def exist?
    @exists
  end
end
