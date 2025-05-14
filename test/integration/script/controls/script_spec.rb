control 'script' do
  describe scriptd_engine('beanshell') do
    it { should exist }
    its('class_name') { should eq 'bsh.util.BeanShellBSFEngine' }
    its('extensions') { should eq 'bsh' }
  end

  describe scriptd_engine('groovy') do
    it { should exist }
    its('class_name') { should eq 'org.gradle.tasks.build.CompileTaskHandler' }
    its('extensions') { should eq 'groovy' }
  end

  describe scriptd_engine('java') do
    it { should exist }
    its('class_name') { should eq 'com.game.core.physics.CollisionManagerr' }
    its('extensions') { should eq 'java' }
  end

  describe scriptd_script('beanshell', 'start', "log = bsf.lookupBean(\"log\");\nlog.debug(\"start-script\");\nlog.debug(\"start-script too\");") do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'stop', "log = bsf.lookupBean(\"log\");\nlog.debug(\"stop-script\");\nlog.debug(\"stop-script also\");\nlog.debug(\"another line but it is indented\");") do
    it { should exist }
  end

  describe scriptd_script('jython', 'stop', '1 + 1') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'reload', "log = bsf.lookupBean(\"log\");\nlog.debug(\"reload-script also\");\nlog.debug(\"another reload line but it is indented and there is a blank line between this one and the last one\");") do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'event', "log = bsf.lookupBean(\"log\");\nlog.debug(\"cpqHoTrapFlags: {}\", cpqHoTrapFlags);\n\nif (\"CRITICAL\".equalsIgnoreCase(trapType)) {\n  log.warn(\"HP device sent a CRITICAL trap!\");\n} else {\n  log.warn(\"Received HP trap that should have had varbind cpqHoTrapFlags in it but it did not.\");\n}\nlog.debug(\"cpqHoMibHealthStatusArray: {}\", cpqHoMibHealthStatusArray);\nif (cpqHoMibHealthStatusArray == null || cpqHoMibHealthStatusArray.length() < 38) {\n  log.warn(\"Received HP trap that should have had varbind cpqHoMibHealthStatusArray in it but it did not.\");\n}\nlog.debug(\"Sending new event: \\n{}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));") do
    it { should exist }
  end
end
