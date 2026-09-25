# frozen_string_literal: true
require 'nokogiri'
require 'xml_helpers'

class Eventconf < Inspec.resource(1)
  include XmlHelpers

  name 'eventconf'

  desc '
    OpenNMS eventconf
  '

  example '
    describe eventconf(\'bogus-events.xml\') do
      it { should exist }
      its(\'content\') {
        should eq <<-EOL
        ...
EOL
      }
      its(\'position\') { should eq 5 }
    end
  '

  def initialize(file_name)
    resp = inspec.http('http://localhost:8980/opennms/api/v2/eventconf/filter/sources?sortBy=name&limit=1&offset=0', auth: { user: 'admin', pass: 'admin' })
    overall_total_records = JSON.parse(resp.body)['totalRecords']
    source_name = file_name.sub(%r{^events/}, '').sub(/\.xml$/, '')
    match = nil
    sources = []
    offset = 0
    limit = 20
    total_records = 1
    begin
      while match.nil? && sources.size < total_records
        resp = inspec.http("http://localhost:8980/opennms/api/v2/eventconf/filter/sources?sortBy=name&filter=#{source_name}&limit=#{limit}&offset=#{offset}", auth: { user: 'admin', pass: 'admin' })
        if resp.status == 204 # none found
          break
        end
        ro = JSON.parse(resp.body)
        total_records = ro['totalRecords']
        s = ro['eventConfSourceList']
        s.each do |source|
          sources << source
          if source['name'] == source_name
            match = source
            break
          end
        end
        offset += limit
      end
    rescue => e
      raise "Unable to retrieve eventconf sources from API. Is OpenNMS running? Error #{e}"
    end
    @exists = !match.nil?
    if @exists
      resp = inspec.http("http://localhost:8980/opennms/api/v2/eventconf/sources/#{match['id']}/events/download", auth: { user: 'admin', pass: 'admin' })
      if resp.status == 200
        @contents = resp.body
      end
      @position = overall_total_records - match['fileOrder']
    end
  end

  def content
    @contents
  end

  def events
    xml_to_hash(Nokogiri::XML(@contents).root)
  end

  def exist?
    @exists
  end

  def self.xml_to_hash(xml)
    xml_to_hash(Nokogiri::XML(xml).root)
  end

  attr_reader :position
end
