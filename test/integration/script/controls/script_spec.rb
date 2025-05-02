control 'script' do
  describe scriptd_engine('beanshell') do
    it { should exist }
    its('class_name') { should eq 'bsh.util.BeanShellBSFEngine' }
    its('extensions') { should eq 'bsh' }
  end

  describe engine('jython') do
    it { should exist }
    its('class_name') { should eq 'org.apache.bsf.engines.JythonEngine' }
    its('extensions') { should eq 'py' }
  end

  describe scriptd_script('beanshell', 'start', "log = bsf.lookupBean(\"log\");\nlog.debug(\"start-script\");\nlog.debug(\"start-script too\");") do
    it { should exist }
  end

  # describe stop_script('beanshell') do
  #   it { should exist }
  #   its('script') do
  #     should include("log = bsf.lookupBean(\"log\");")
  #     should include("log.debug(\"stop-script\");")
  #     should include("log.debug(\"stop-script also\");")
  #     should include("log.debug(\"another line but it is indented\");")
  #   end
  # end

  # describe stop_script('jython') do
  #   it { should exist }
  #   its('script') { should eq("1 + 1") }
  # end

  # describe reload_script('beanshell') do
  #   it { should exist }
  #   its('script') do
  #     should include("log = bsf.lookupBean(\"log\");")
  #     should include("log.debug(\"reload-script also\");")
  #     should include("log.debug(\"another reload line but it is indented and there is a blank line between this one and the last one\");")
  #   end
  # end

  # everything below is currently commented out
  # return

  # describe event_script('beanshell') do
  #   it { should exist }
  #   its('uei') do
  #     should eq 'uei.opennms.org/vendor/compaqhp/traps/cpqHoMibHealthStatusArrayChangeTrap'
  #   end
  #   its('script') do
  #     should include(
  #       "log = bsf.lookupBean(\"log\");\n" \
  #       "log.debug(\"cpqHoTrapFlags: {}\", cpqHoTrapFlags);\n\n" \
  #       "if (\"CRITICAL\".equalsIgnoreCase(trapType)) {\n" \
  #       "    log.warn(\"HP device sent a CRITICAL trap!\");\n" \
  #       "} else {\n" \
  #       "    log.warn(\"Received HP trap that should have had varbind cpqHoTrapFlags in it but it did not.\");\n" \
  #       "}\n" \
  #       "log.debug(\"cpqHoMibHealthStatusArray: {}\", cpqHoMibHealthStatusArray);\n" \
  #       "if (cpqHoMibHealthStatusArray == null || cpqHoMibHealthStatusArray.length() < 38) {\n" \
  #       "    log.warn(\"Received HP trap that should have had varbind cpqHoMibHealthStatusArray in it but it did not.\");\n" \
  #       "}\n" \
  #       "log.debug(\"Sending new event: \\n{}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));"
  #     )
  #   end
  # end

  # ...and so on for the rest of the event_script blocks...
end
