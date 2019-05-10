# frozen_string_literal: true
require 'rexml/document'
class Target < Inspec.resource(1)
  name 'target'

  desc '
    OpenNMS target
  '

  example '
    describe target(\'destination_path_name\', \'target_name\', \'escalate\'=\'false\') do
      its(\'commands\') { should eq [\'javaEmail\'] }
    end
  '

  def initialize(destination_path_name, target_name, escalate = false)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/destinationPaths.xml').content)
    xpath = "/destinationPaths/path[@name='#{destination_path_name}']/"
    xpath += 'escalate[' if escalate
    xpath += "target[name[text() = '#{target_name}']]"
    xpath += ']' if escalate
    t_el = doc.elements[xpath]
    @exists = !t_el.nil?
    if @exists
      @params = {}
      @params[:escalate_delay] = t_el.attributes['delay'] if escalate && !t_el.attributes['delay'].nil?
      t_el = t_el.elements['target'] if escalate
      commands = []
      t_el.each_element('command') do |cel|
        commands.push cel.text.to_s
      end
      @params[:commands] = commands
      unless t_el.elements['autoNotify'].nil?
        @params[:auto_notify] = t_el.elements['autoNotify'].texts.join("\n")
      end
      unless t_el.attributes['interval'].nil?
        @params[:interval] = t_el.attributes['interval'].to_s
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
