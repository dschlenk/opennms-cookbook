require 'rexml/document'
class ScriptdScript < Inspec.resource(1)
  name 'scriptd_script'

  desc '
    Custom InSpec resource to validate OpenNMS scriptd scripts in config file
  '
  example '
      describe scriptd_script(\'beanshell\', \'event\', \'script\', [\'uei.opennms.org/anUei\']) do
        it { should_exist }
      end
  '
  def initialize(language, type, script, ueis = nil)
    @exists = false
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/scriptd-configuration.xml').content)
    puts doc # TODO: remove once working
    script_el = doc.root.elements["/scriptd-configuration/#{type}-script[@language = '#{language}']"]
    unless script_el.nil?
      s = script_el.texts.join("\n")
      if s.eql?(script)
        if type.eql?('event') && !ueis.nil?
          if
            ul = []
            script_el.each_element('uei') do |u|
              ul.push u.attributes['name']
            end
            @exists = ul.sort.eql?(ueis.sort)
          end
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
