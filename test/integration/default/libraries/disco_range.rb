# frozen_string_literal: true
require 'rexml/document'
class DiscoRange < Inspec.resource(1)
  name 'disco_range'

  desc '
    OpenNMS disco_range
  '

  example '
    describe disco_range(\'type\', \'range_begin\', \'range_end\') do
      it { should exist }
      its(\'retry_count\') { should eq 37 }
      its(\'discovery_timeout\') { should eq 6000 }
      its(\'location\') { should eq \'Detroit\' }
      its(\'foreign_source\') { should eq \'disco-source\' }
    end
  '

  def initialize(type, range_begin, range_end)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/discovery-configuration.xml').content)
    xpath = "/discovery-configuration/#{type}-range[begin[text() = '#{range_begin}']]"# and end[text() = '#{range_end}']]"
    puts xpath
    r_el = nil
    # well this is ugly, but apparently REXML can't handle siblings in a compound predicate each with text equality checks
    doc.each_element(xpath) do |rr|
      e_el = rr.elements["end[text() = '#{range_end}']"]
      next if e_el.nil?
      r_el = rr
    end
    @exists = !r_el.nil?
    if @exists
      @params = {}
      @params[:retry_count] = r_el.attributes['retries'].to_i
      @params[:discovery_timeout] = r_el.attributes['timeout'].to_i
      @params[:location] = r_el.attributes['location']
      @params[:foreign_source] = r_el.attributes['foreign-source']
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
