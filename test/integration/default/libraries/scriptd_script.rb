require 'rexml/document'

class ScriptdScript < Inspec.resource(1)
  name 'scriptd_script'

  desc '
    Custom InSpec resource to validate OpenNMS scriptd scripts in config file
  '

  example '
    describe scriptd_script("beanshell", "event", "log = bsf.lookupBean(\"log\")", ["uei.opennms.org/anUei"]) do
      it { should exist }
    end
  '

  attr_reader :type, :uei, :script

  def initialize(language, type, script, ueis = nil)
    @exists = false
    @type = type
    @uei = uei
    @script = nil

    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/scriptd-configuration.xml').content)
    xpath = "/scriptd-configuration/#{type}-script[@language = '#{language}']"
    puts "script xpath: #{xpath}"
    se = doc.root.elements[xpath]
    unless se.nil?
      doc.each_element(xpath) do |script_el|
        @script = script_el.texts.join("\n").strip
        puts "checking #{@script} for a match"
        next unless @script == script.strip
        puts "#{@script} matches"
        if type == 'event' && ueis
          puts 'type is event, checking if ueis match'
          ul = []
          script_el.each_element('uei') { |u| ul << u.attributes['name'] }
          puts "ul.sort == ueis.sort ? #{ul.sort} == #{ueis.sort}"
          @exists = ul.sort == ueis.sort
        else
          @exists = true
        end
      end
    end
  end

  def exist?
    @exists
  end
end
