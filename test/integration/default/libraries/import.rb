require 'rexml/document'
class Import < Inspec.resource(1)
  name 'import'

  desc '
    OpenNMS import
  '

  example '
    describe import(\'node name\', \'foreign source name\') do
      it { should exist }
    end
  '

  def initialize(name, foreign_source)
    doc = REXML::Document.new(inspec.file("/opt/opennms/etc/imports/#{name}.xml").content)
    i_el = doc.elements["/model-import[@foreign-source = '#{foreign_source}']"]
    @exists = !i_el.nil?
  end

  def exist?
    @exists
  end

end
