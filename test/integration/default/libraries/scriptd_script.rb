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

    script_el = doc.root.elements["/scriptd-configuration/#{type}-script[@language = '#{language}']"]
    unless script_el.nil?
      @script = script_el.texts.join("\n").strip
      if @script == script.strip
        if type == 'event' && ueis
          ul = []
          script_el.each_element('uei') { |u| ul << u.attributes['name'] }
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
