require 'java-properties'
require 'tempfile'
class ResponseGraph < Inspec.resource(1)
  name 'response_graph'

  desc '
    OpenNMS response_graph
  '

  example '
    describe response_graph(\'onms\') do
      it { should exist }
      its(\'long_name\') { should eq \'ONMS\' }
      its(\'columns\') { should eq [\'onms\'] }
      its(\'type\') { should eq [\'responseTime\', \'distributedStatus\'] }
      its(\'command\') { should eq "--title=\"ONMS Response Time\" \\\n --vertical-label=\"Seconds\" \\\n DEF:rtMills={rrd1}:onms:AVERAGE \\\n DEF:minRtMicro={rrd1}:onms:MIN \\\n DEF:maxRtMicro={rrd1}:onms:MAX \\\n CDEF:rt=rtMills,1000,/ \\\n CDEF:minRt=minRtMills,1000,/ \\\n CDEF:maxRt=maxRtMills,1000,/ \\\n LINE1:rt#0000ff:\"Response Time\" \\\n GPRINT:rt:AVERAGE:\" Avg  \\\\: %8.2lf %s\" \\\n GPRINT:rt:MIN:\"Min  \\\\: %8.2lf %s\" \\\n GPRINT:rt:MAX:\"Max  \\\\: %8.2lf %s\\\\n\"" }
    end
  '

  def initialize(graph_name)
    gf = inspec.file('/opt/opennms/etc/response-graph.properties').content
    # initializing the props object changed because the `java-propertes` library used changed
    props = JavaProperties.parse(gf)
    # accessing items in `props` has to be done via symbol now instead of with a string
    values = props[:reports].split(/,\s*/) unless props[:reports].nil?
    found = values.include?(graph_name) unless values.nil?
    @exists = found
    if @exists
      @long_name = props["report.#{graph_name}.name".to_sym]
      @columns = props["report.#{graph_name}.columns".to_sym].split(',')
      @columns.each do |c|
        c.chomp!
        c.lstrip!
      end
      @type = props["report.#{graph_name}.type".to_sym].split(',')
      @type.each do |t|
        t.chomp!
        t.lstrip!
      end
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
