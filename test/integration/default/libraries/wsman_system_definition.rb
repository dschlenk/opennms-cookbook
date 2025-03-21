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
    doc = REXML::Document.new(inspec.file(fn).content)
    s_el = doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"]
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    unless s_el.elements['include-group'].nil?
      @params[:groups] = []
      s_el.each_element('include-group') do |g|
        @params[:groups].push g.texts.collect(&:value).join('')
      end
    end
    @params[:rule] = s_el.elements['rule'].texts.collect(&:value).join('') unless s_el.elements['rule'].nil?
    @params[:file_name] = fn
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
      file = inspec.file('/opt/opennms/etc/wsman-datacollection-config.xml').content
      doc = REXML::Document.new file

      exists = !doc.elements["/wsman-datacollection-config/system-definition[@name='#{name}']"].nil?
      if exists
        system_def_file = '/opt/opennms/etc/wsman-datacollection-config.xml'
      end
    end
    system_def_file
  end
end
