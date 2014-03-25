$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'java_properties'

module Graph
  def graph_file_exists?(filename, node)
    ::File.exists?("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{filename}")
  end
  def graph_exists?(name, node)
    # check main graph file first
    props = JavaProperties::Properties.new("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties")
    found = false
    values = props[:reports].split(',') unless props[:reports].nil?
    found = values.include?(name) unless values.nil?
    if !found
      Dir.foreach("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d") do |gfile|
        next if gfile !~ /.*\.properties$/
        props = JavaProperties::Properties.new("#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{gfile}")
        values = props[:reports].split(',') unless props[:reports].nil?
        found = values.include?(name) unless values.nil?
        break if found
      end
    end 
    found
  end
  # do this with line-by-line parsing since JavaProperties doesn't support non-destructive editing
  # and OpenNMS prefers that each report is listed on it's own line.
  def add_collection_graph(new_resource, node)
    fn = "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties"
    if !new_resource.file.nil?
      fn = "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties.d/#{new_resource.file}"
    end
    Chef::Log.info "fn is #{fn}"
    lines = []
    reports_start = false
    reports_end = false
    ::File.readlines(fn).each do |line| 
      Chef::Log.info "current line: #{line}"
      if !reports_start 
        if line =~ /^reports=.*$/
          Chef::Log.info "found line"
          reports_start = true
          # if first line of reports isn't extended, add here
          if line !~ /.*\\$/
            Chef::Log.info "Single report in reports"
            lines.push "#{line.chomp}, \\\n"
            lines.push new_resource.name
            reports_end = true
          else
            Chef::Log.info "Multple reports in reports"
            lines.push line
          end 
        else
          lines.push line
          Chef::Log.info "no reports line yet"
        end
      elsif !reports_end && line !~ /.*\\$/
        Chef::Log.info "found end of reports"
        lines.push (line + ", \\")
        lines.push new_resource.name
      else
        Chef::Log.info "reports mess is over, just appending a line."
        lines.push line
      end
    end
    # add a blank line for teh pretties
    lines.push "\n"
    # add the report definition
    lines.push "report.#{new_resource.name}.name=#{new_resource.long_name}"
    lines.push "report.#{new_resource.name}.columns=#{new_resource.columns.join(', ')}"
    lines.push "report.#{new_resource.name}.type=#{new_resource.type}"
    lines.push "report.#{new_resource.name}.command=#{new_resource.command}"

    # write out the modified properties to the file
    ::File.open(fn, "w"){ |file| file.puts(lines) }
  end
end
