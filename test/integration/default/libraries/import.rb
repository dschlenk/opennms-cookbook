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
    doc = REXML::Document.new(inspec.http("http://localhost:8980/opennms/rest/requisitions/#{name}", auth: { user: 'admin', pass: 'admin' }).body)
    i_el = doc.elements["/model-import[@foreign-source = '#{foreign_source}']"]
    @exists = !i_el.nil?
  end

  def exist?
    @exists
  end
end
