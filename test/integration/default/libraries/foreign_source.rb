# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ForeignSource < Inspec.resource(1)
  name 'foreign_source'

  desc '
    OpenNMS foreign_source
  '

  example '
    describe foreign_source(\'name\', 1237) do
      it { should exist }
      its(\'scan_interval\') { should eq \'1w\' }
    end
  '

  def initialize(name, port = 8980)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:#{port}/opennms/rest/foreignSources/#{name}").normalize.to_str
    fs = RestClient.get(parsed_url)
    doc = REXML::Document.new(fs)
    fs_el = doc.elements["/foreign-source[@name = '#{name}']"]
    @exists = !fs_el.nil?
    @scan_interval = fs_el.elements['scan-interval'].texts.collect(&:value).join("\n") if @exists
  end

  def exist?
    @exists
  end

  attr_reader :scan_interval
end
