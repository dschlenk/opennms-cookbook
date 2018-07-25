# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class Import < Inspec.resource(1)
  name 'import'

  desc '
    OpenNMS import
  '

  example '
    describe import(\'group name\', \'foreign source name\') do
      it { should exist }
    end
  '

  def initialize(name, foreign_source)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:8980/opennms/rest/requisitions/#{name}").normalize.to_str
    begin
      req = RestClient.get(parsed_url)
    rescue StandardError
      @exists = false
      return
    end
    doc = REXML::Document.new(req)
    i_el = doc.elements["/model-import[@foreign-source = '#{foreign_source}']"]
    @exists = !i_el.nil?
  end

  def exist?
    @exists
  end
end
