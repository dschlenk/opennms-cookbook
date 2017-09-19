# frozen_string_literal: true
require 'rexml/document'
class Eventconf < Inspec.resource(1)
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
    ef = inspec.file("/opt/opennms/etc/events/#{file_name}")
    mef = inspec.file("/opt/opennms/etc/eventconf.xml")
    mdoc = REXML::Document.new(mef.content, ignore_whitespace_nodes: ['events'])
    ef_el = mdoc.root.elements["/events/event-file[text() = 'events/#{file_name}']"]
    @exists = ef.exist? && !ef_el.nil?
    @contents = ef.content if @exists
    @position = mdoc.root.index(ef_el) if @exists
  end

  def content
    @contents
  end

  def exist?
    @exists
  end

  def position
    @position
  end
end
