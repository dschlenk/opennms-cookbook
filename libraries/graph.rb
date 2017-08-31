
# frozen_string_literal: true
module Graph
  def new_graph_file(file, node)
    f = ::File.new("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{file}", 'w')
    ::File.open(f, 'w') { |new_file| new_file.puts(["reports=\n", "\n"]) }
  end

  def graph_file_exists?(filename, node)
    ::File.exist?("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{filename}")
  end

  def graph_exists?(name, type, node)
    found = false
    if type == 'collection'
      found = check_file_for_graph("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties", name)
      unless found
        Dir.foreach("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d") do |gfile|
          next if gfile !~ /.*\.properties$/
          found = check_file_for_graph("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{gfile}", name)
          break if found
        end
      end
    elsif type == 'response'
      found = check_file_for_graph("#{node['opennms']['conf']['home']}/etc/response-graph.properties", name)
    end
    found
  end

  def check_file_for_graph(file, name)
    require 'java_properties'
    props = JavaProperties::Properties.new(file)
    found = false
    values = props[:reports].split(/,\s*/) unless props[:reports].nil?
    found = values.include?(name) unless values.nil?
    found
  end

  # do this with line-by-line parsing since JavaProperties doesn't support non-destructive editing
  # and OpenNMS prefers that each report is listed on it's own line.
  def add_collection_graph(new_resource, node)
    fn = "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties"
    unless new_resource.file.nil?
      fn = "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
    end
    lines = add_report(fn, new_resource.name)
    # add a blank line for teh pretties
    lines.push "\n"
    # add the report definition
    lines.push "report.#{new_resource.name}.name=#{new_resource.long_name}"
    lines.push "report.#{new_resource.name}.columns=#{new_resource.columns.join(', ')}"
    lines.push "report.#{new_resource.name}.type=#{new_resource.type}"
    lines.push "report.#{new_resource.name}.command=#{new_resource.command}"

    # write out the modified properties to the file
    ::File.open(fn, 'w') { |file| file.puts(lines) }
  end

  # response graphs are more predictably generated so more attributes can be implied
  def add_response_graph(new_resource, node)
    fn = "#{node['opennms']['conf']['home']}/etc/response-graph.properties"
    lines = add_report(fn, new_resource.name)
    long_name = (new_resource.long_name.nil? ? new_resource.name.upcase : new_resource.long_name)
    columns = (new_resource.columns.nil? ? new_resource.name : new_resource.columns.join(', '))
    command = new_resource.command
    if command.nil?
      command = "--title=\"#{long_name} Response Time\" \\\n"
      command += " --vertical-label=\"Seconds\" \\\n"
      command += " DEF:rtMills={rrd1}:#{new_resource.name}:AVERAGE \\\n"
      command += " DEF:minRtMicro={rrd1}:#{new_resource.name}:MIN \\\n"
      command += " DEF:maxRtMicro={rrd1}:#{new_resource.name}:MAX \\\n"
      command += " CDEF:rt=rtMills,1000,/ \\\n"
      command += " CDEF:minRt=minRtMills,1000,/ \\\n"
      command += " CDEF:maxRt=maxRtMills,1000,/ \\\n"
      command += " LINE1:rt#0000ff:\"Response Time\" \\\n"
      command += " GPRINT:rt:AVERAGE:\" Avg  \\\\: %8.2lf %s\" \\\n"
      command += " GPRINT:rt:MIN:\"Min  \\\\: %8.2lf %s\" \\\n"
      command += ' GPRINT:rt:MAX:"Max  \\\\: %8.2lf %s\\\\n"'
    end
    lines.push "\n"
    lines.push "report.#{new_resource.name}.name=#{long_name}"
    lines.push "report.#{new_resource.name}.columns=#{columns}"
    lines.push "report.#{new_resource.name}.type=#{new_resource.type.join(', ')}"
    lines.push "report.#{new_resource.name}.command=#{command}"
    ::File.open(fn, 'w') { |file| file.puts(lines) }
  end

  # add report 'name' to the reports comma separated list in file 'fn'
  # rubocop:disable Metrics/BlockNesting
  def add_report(fn, name)
    lines = []
    reports_start = false
    reports_end = false
    ::File.readlines(fn).each do |line|
      if !reports_start
        if line =~ /^reports=(.*)$/
          reports_start = true
          values = Regexp.last_match(1)
          if line !~ /.*\\$/
            # check to make sure at least one report is listed here
            if values !~ /^\s*$/
              lines.push "#{line.chomp}, \\\n"
              lines.push name
            else
              lines.push "#{line.chomp}#{name}\n"
            end
            reports_end = true
          else
            lines.push line
          end
        else
          lines.push line
        end
      elsif !reports_end && line !~ /.*\\$/
        lines.push "#{line.chomp}, \\\n"
        lines.push name
        reports_end = true
      else
        lines.push line
      end
    end
    lines
  end
  # rubocop:enable Metrics/BlockNesting
end
