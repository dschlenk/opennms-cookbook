opennms_scriptd_script 'beanshell-start' do
  language 'beanshell'
  type 'start'
  script 'bsf.lookupBean("log");'
end

opennms_scriptd_script 'groovy-stop' do
  language 'groovy'
  type 'stop'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'java-reload' do
  language 'java'
  type 'reload'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'beanshell-event' do
  language 'beanshell'
  type 'event'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log");'
end

opennms_scriptd_script 'beanshell-start-extended' do
  language 'beanshell'
  type 'start'
  script "log = bsf.lookupBean(\"log\");\nlog.info(\"Beanshell start script initialized.\");\nString user = System.getProperty(\"user.name\");\nlog.info(\"Running as user: \" + user);"
end

opennms_scriptd_script 'groovy-stop-extended' do
  language 'groovy'
  type 'stop'
  script 'def log = bsf.lookupBean("log"); def now = new Date(); log.info("Groovy stop script executed at: ${now}"); if (now.hours > 18) { log.warn("Script stopped after hours."); }'
end

opennms_scriptd_script 'java-reload-extended' do
  language 'java'
  type 'reload'
  script "log = bsf.lookupBean(\"log\");\ntry { log.info(\"Reloading Java script.\");\nString version = System.getProperty(\"java.version\");\nlog.info(\"Java version: \" + version);\n} catch (Exception e) {\nlog.error(\"Error during reload: \" + e.getMessage());\n}"
end

opennms_scriptd_script 'beanshell-event-multiuei' do
  language 'beanshell'
  type 'event'
  uei 'uei.opennms.org/cheftest/nodeDown,uei.opennms.org/cheftest/nodeUp'
  script 'log = bsf.lookupBean("log"); String uei = event.getUei(); String node = event.getParm("nodeLabel").getValue(); log.info("Received UEI: " + uei + " for node: " + node); if (uei.contains("nodeDown")) { log.warn("ALERT: Node " + node + " is DOWN"); } else if (uei.contains("nodeUp")) { log.info("INFO: Node " + node + " is UP"); }'
end

opennms_scriptd_script 'groovy-event-interface' do
  language 'groovy'
  type 'event'
  uei 'uei.opennms.org/cheftest/interfaceDown,uei.opennms.org/cheftest/interfaceUp'
  script 'def log = bsf.lookupBean("log"); def uei = event.getUei(); def iface = event.getParm("interface")?.value ?: "unknown"; log.info("Event received: ${uei} for interface: ${iface}"); if (uei.contains("interfaceDown")) { log.error("Interface ${iface} is DOWN"); } else if (uei.contains("interfaceUp")) { log.info("Interface ${iface} is UP"); }'
end
