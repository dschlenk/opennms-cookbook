opennms_scriptd_script 'beanshell' do
  type 'start'
  script "log = bsf.lookupBean(\"log\");\nlog.debug(\"start-script\");\nlog.debug(\"start-script too\");"
end

opennms_scriptd_script 'beanshell' do
  type 'stop'
  script "log = bsf.lookupBean(\"log\");\nlog.debug(\"stop-script\");\nlog.debug(\"stop-script also\");\nlog.debug(\"another line but it is indented\");"
end

opennms_scriptd_script 'jython' do
  type 'stop-jython'
  script '1 + 1'
end

opennms_scriptd_script 'beanshell' do
  type 'reload'
  script "log = bsf.lookupBean(\"log\");\nlog.debug(\"reload-script also\");\nlog.debug(\"another reload line but it is indented and there is a blank line between this one and the last one\");"
end

opennms_scriptd_script 'beanshell' do
  type 'event'
  script "log = bsf.lookupBean(\"log\");\nlog.debug(\"cpqHoTrapFlags: {}\", cpqHoTrapFlags);\n\nif (\"CRITICAL\".equalsIgnoreCase(trapType)) {\n  log.warn(\"HP device sent a CRITICAL trap!\");\n} else {\n  log.warn(\"Received HP trap that should have had varbind cpqHoTrapFlags in it but it did not.\");\n}\nlog.debug(\"cpqHoMibHealthStatusArray: {}\", cpqHoMibHealthStatusArray);\nif (cpqHoMibHealthStatusArray == null || cpqHoMibHealthStatusArray.length() < 38) {\n  log.warn(\"Received HP trap that should have had varbind cpqHoMibHealthStatusArray in it but it did not.\");\n}\nlog.debug(\"Sending new event: \\n{}\", org.opennms.core.xml.JaxbUtils.marshal(bldr.getEvent()));"
end
