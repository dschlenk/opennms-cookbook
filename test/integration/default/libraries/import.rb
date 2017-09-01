# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
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
    req = RestClient.get("http://admin:admin@localhost:8980/opennms/rest/requisitions/#{name}")
    doc = REXML::Document.new(req)
    i_el = doc.elements["/model-import[@foreign-source = '#{foreign_source}']"]
    @exists = !i_el.nil?
  end

  def exist?
    @exists
  end
end
