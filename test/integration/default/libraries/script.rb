require 'rexml/document'

module Inspec::Resources
  class ScriptdConfiguration < Inspec.resource(1)

  desc 'Custom InSpec resource to validate OpenNMS scriptd configuration'

  example
      describe scriptd_configuration('/opt/opennms/etc/scriptd-configuration.xml') do
        its('engines') { should include({ language: 'groovy', class_name: 'org.opennms.groovy.GroovyScriptEngine' }) }
      end

  end
end
