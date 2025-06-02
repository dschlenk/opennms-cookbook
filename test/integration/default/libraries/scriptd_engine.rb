require 'rexml/document'

class ScriptdEngine < Inspec.resource(1)
  name 'scriptd_engine'

  desc '
    Custom InSpec resource to validate OpenNMS scriptd engine in config file
  '

  example '
      describe scriptd_engine(\'beanshell\') do
        it { should exist }
        its(\'class_name\') { should eq \'bsh.util.BeanShellBSFEngine\' }
        its(\'extensions\') { should eq \'bsh\' }
      end
  '

  attr_reader :class_name, :extensions

  def initialize(language)
    @exists = false
    @class_name = nil
    @extensions = nil
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/scriptd-configuration.xml').content)
    lang = doc.root.elements["/scriptd-configuration/engine[@language = '#{language}']"]
    unless lang.nil?
      @exists = true
      @class_name = lang.attributes['className']
      @extensions = lang.attributes['extensions']
    end
  end

  def exist?
    @exists
  end
end
