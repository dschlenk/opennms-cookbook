# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
class ForeignSource < Inspec.resource(1)
  name 'foreign_source'

  desc '
    OpenNMS foreign_source
  '

  example '
    describe foreign_source(\'name\') do
      it { should exist }
      its(\'scan_interval\') { should eq \'1w\' }
    end
  '

  def initialize(name)
    fs = RestClient.get("http://admin:admin@localhost:8980/opennms/rest/foreignSources/#{name}")
    doc = REXML::Document.new(fs)
    fs_el = doc.elements["/foreign-source[@name = '#{name}']"]
    @exists = !fs_el.nil?
    @scan_interval = fs_el.elements['scan-interval'].texts.join('\n')
  end

  def exist?
    @exists
  end

  attr_reader :scan_interval
end
