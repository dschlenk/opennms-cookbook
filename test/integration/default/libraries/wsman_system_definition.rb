# frozen_string_literal: true
class WsmanSystemDefinition < Inspec.resource(1)
  name 'system_definition'

  desc '
    OpenNMS WS-Man system_definition
  '

  example '
    describe system_definition(\'Dell iDRAC (All Version)\') do
      it { should exist }
      its(\'groups\') { should eq [\'drac-system\', \'drac-power-supply\', \'drac-system-board\'] }
    end
  '

  def initialize(name)
    fn = find_system_definition(name)
    doc = REXML::Document.new(inspec.file(fn).content)
    s_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"]
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    unless s_el.elements['include-group'].nil?
      @params[:groups] = []
      s_el.each_element('include-group') do |g|
        @params[:groups].push g.texts.join('')
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  def find_system_definition(name)
    system_def_file = nil
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml", 'r')
    doc = REXML::Document.new file

    exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?

    if exists
      system_def_file = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection-config.xml"
      return system_def_file
    else
      Dir.foreach("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d") do |group|
        next if group !~ /.*\.xml$/
        file = ::File.new("#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}", 'r')
        doc = REXML::Document.new file
        file.close
        exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
        if exists
          @current_resource.file_path = "#{node['opennms']['conf']['home']}/etc/wsman-datacollection.d/#{group}"
          system_def_file = @current_resource.file_path
          return system_def_file
        end
      end
      system_def_file
    end
  end
end
