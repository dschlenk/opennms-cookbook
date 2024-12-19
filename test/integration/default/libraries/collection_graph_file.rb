# frozen_string_literal: true
require 'rexml/document'
class CollectionGraphFile < Inspec.resource(1)
  name 'collection_graph_file'

  desc '
    OpenNMS collection_graph_file
  '

  example '
    describe collection_graph_file(\'mib2-graph.properties\') do
      it { should exist }
      its(\'content\') {
        should eq <<-EOL
reports=mib2.HCbits, \\
mib2.bits, \\
...
EOL
      }
    end
  '

  def initialize(graph_file)
    @graph_file = graph_file
    gf = inspec.file("/opt/opennms/etc/snmp-graph.properties.d/#{graph_file}")
    @exists = gf.exist?
    @content = gf.content if @exists
    @md5sum = gf.md5sum if @exists
  end

  attr_reader :content

  attr_reader :md5sum

  def exist?
    @exists
  end
end
