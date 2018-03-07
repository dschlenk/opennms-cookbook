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
    describe import_node_interface(\'ip_addr\', \'foreign_source_name\', \'foreign_id\') do
      it { should exist }
      its(\'managed\') { should be true }
      its(\'snmp_primary\') { should eq \'P\' }
    end
  '

  def initialize(ip_addr, foreign_source_name, foreign_id)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:8980/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{foreign_id}/interfaces/#{ip_addr}").normalize.to_str
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
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end
