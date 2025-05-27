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
    @script = nil
    @uei = ueis.is_a?(String) ? [ueis] : ueis
 
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/scriptd-configuration.xml').content)
    xpath = "/scriptd-configuration/#{type}-script[@language = '#{language}']"
    puts "script xpath: #{xpath}"
 
    unless doc.root.elements[xpath].nil?
      doc.root.elements.each(xpath) do |script_el|
        # this gives us valid XML text, but we want the value instead
        # @script = script_el.texts.join("\n").strip
        @script = ''
        script_el.texts.each do |t|
          @script += t.value
        end
        @script = @script.strip
        puts "checking #{@script} for a match"
        next unless @script == script.strip
        puts "#{@script} matches"
 
        if type == 'event' && @uei
          puts 'type is event, checking if ueis match'
          ul = []
          script_el.each_element('uei') do |u|
            puts "Found uei: #{u.attributes['name']}"
            ul << u.attributes['name']
          end
          puts "ul.sort == @uei.sort ? #{ul.sort} == #{@uei.sort}"
          @exists = ul.sort == @uei.sort
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
