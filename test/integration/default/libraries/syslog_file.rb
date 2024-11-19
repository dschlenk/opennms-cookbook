require 'rexml/document'
class SyslogFile < Inspec.resource(1)
  name 'syslog_file'

  desc '
    OpenNMS syslog_file
  '

  example '
    describe syslog_file(\'file.syslog.xml\') do
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
    ef = inspec.file("/opt/opennms/etc/syslog/#{file_name}")
    mef = inspec.file('/opt/opennms/etc/syslogd-configuration.xml')
    mdoc = REXML::Document.new(mef.content, ignore_whitespace_nodes: ['events'])
    ef_el = mdoc.root.elements["/syslogd-configuration/import-file[text() = 'syslog/#{file_name}']"]
    @exists = ef.exist? && !ef_el.nil?
    @contents = ef.content if @exists
    @position = mdoc.root.index(ef_el) - 1 if @exists
  end

  def content
    @contents
  end

  def exist?
    @exists
  end

  attr_reader :position
end
