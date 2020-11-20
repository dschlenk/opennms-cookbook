# frozen_string_literal: true
class WsmanSystemDefinition < Inspec.resource(1)
  name 'wsman_system_definition'

  desc '
    OpenNMS wsman_system_definition
  '

  example '
    describe system_definition(\'Dell iDRAC (All Version)\') do
      it { should exist }
      its(\'groups\') { should eq [\'drac-system\', \'drac-power-supply\', \'drac-system-board\'] }
    end
  '

  def initialize(name)
    fn = find_system_definition(name)
    puts 'System Definition name : ' + fn
    doc = REXML::Document.new(inspec.file(fn).content)
    s_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"]
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    unless s_el.elements['include-group'].nil?
      @params[:groups] = []
      s_el.each_element('include-group') do |g|
        puts 'Group name : ' + g.to_s
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
    files = inspec.command('ls -1 /opt/opennms/etc/wsman-datacollection.d').stdout
    files.each_line do |group|
      group.chomp!
      next if group !~ /.*\.xml$/
      file = inspec.file("/opt/opennms/etc/wsman-datacollection.d/#{group}").content
      doc = REXML::Document.new file
      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
      if exists
        system_def_file = "/opt/opennms/etc/wsman-datacollection.d/#{group}"
        break
      end
    end

    if system_def_file.nil?
      file = ::File.new('/opt/opennms/etc/wsman-datacollection-config.xml', 'r')
      doc = REXML::Document.new file

      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
      if exists
        system_def_file = '/opt/opennms/etc/wsman-datacollection-config.xml'
      end
    end
    system_def_file
  end
end
