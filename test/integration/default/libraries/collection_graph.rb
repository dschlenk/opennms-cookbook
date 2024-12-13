require 'java-properties'
require 'tempfile'
class CollectionGraph < Inspec.resource(1)
  name 'collection_graph'

  desc '
    OpenNMS collection_graph
  '

  example '
    describe collection_graph(\'mib2-graph.properties\', \'mib2.HCbits\') do
      it { should exist }
      its(\'long_name\') { should eq \'Bits In/Out (High Speed)\' }
      its(\'columns\') { should eq %w(ifHCInOctets ifHCOutOctets) }
      its(\'type\') { should eq \'interfaceSnmp\' }
      its(\'command\') {
        should eq <<-EOL
--title="Bits In/Out (High Speed)" \\
...
EOL
      }
    end
  '

  def initialize(graph_file, graph_name)
    gf = inspec.file("/opt/opennms/etc/snmp-graph.properties.d/#{graph_file}").content
    tf = Tempfile.new('inspec-gf')
    tf.write(gf)
    tf.close
    props = JavaProperties::Properties.new(tf.path)
    values = props[:reports].split(/,\s*/) unless props['reports'].nil?
    found = values.include?(graph_name) unless values.nil?
    @exists = found
    if @exists
      @long_name = props["report.#{graph_name}.name".to_sym]
      @columns = props["report.#{graph_name}.columns".to_sym].split(',')
      @columns.each do |c|
        c.chomp!
        c.lstrip!
      end
      @type = props["report.#{graph_name}.type".to_sym]
      @command = props["report.#{graph_name}.command".to_sym]
    end
  end

  def exist?
    @exists
  end

  attr_reader :long_name

  attr_reader :columns

  attr_reader :type

  attr_reader :command
end
