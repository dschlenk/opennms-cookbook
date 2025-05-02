require 'rexml/document'
class ScriptdEngine < Inspec.resource(1)
  name 'scriptd_engine'

  desc '
    Custom InSpec resource to validate OpenNMS scriptd engine in config file
  '
  example '
      describe scriptd_engine(\'beanshell\') do
        it { should_exist }
        its(\'className\') { should eq \'bsh.util.BeanShellBSFEngine\' }
        its(\'extensions\') { should eq \'bsh\' }
      end
  '
  def initialize(language)
    @exists = false
    @className = nil
    @extensions = nil
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/scriptd-configuration.xml').content)
    puts doc # TODO: remove once working
    lang = doc.root.elements["/scriptd-configuration/engine[@language = '#{language}']"]
    unless lang.nil?
      @exists = true
      @className = lang.attributes['className']
      @extensions = lang.attributes['extensions']
    end
  end

  def exist?
    @exists
  end
end
