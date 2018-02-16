# frozen_string_literal: true
require 'rexml/document'
class Target < Inspec.resource(1)
  name 'target'

  desc '
    OpenNMS target
  '

  example '
    describe target(\'destination_path_name\', \'target_name\') do
      its(\'commands\') { should eq [\'javaEmail\'] }
    end
  '

  def initialize(destination_path_name, target_name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/destinationPaths.xml').content)
    t_el = doc.elements["/destinationPaths/path[@name = '#{destination_path_name}']/target[name[text() = '#{target_name}']]"]
    @exists = !t_el.nil?
    @params = {}
    commands = []
    t_el.each_element('command') do |cel|
      commands.push cel.text.to_s
    end
    @params[:commands] = commands
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end
