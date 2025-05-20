# Original scripts
opennms_scriptd_script 'beanshell-start' do
  language 'beanshell'
  type 'start'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'groovy-stop' do
  language 'groovy'
  type 'stop'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'jython-reload' do
  language 'jython'
  type 'reload'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'beanshell-event' do
  language 'beanshell'
  type 'event'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

# Extended and more complex scripts

opennms_scriptd_script 'beanshell-start-extended' do
  language 'beanshell'
  type 'start'
  script <<-EOS
    log = bsf.lookupBean("log");
    log.info("Beanshell start script initialized.");
    String user = System.getProperty("user.name");
    log.info("Running as user: " + user);
  EOS
end

opennms_scriptd_script 'groovy-stop-extended' do
  language 'groovy'
  type 'stop'
  script <<-EOS
    def log = bsf.lookupBean("log")
    def now = new Date()
    log.info("Groovy stop script executed at: ${now}")
    if (now.hours > 18) {
      log.warn("Script stopped after hours.")
    }
  EOS
end

opennms_scriptd_script 'jython-reload-extended' do
  language 'jython'
  type 'reload'
  script <<-EOS
    log = bsf.lookupBean("log")
    try:
        log.info("Reloading Jython script.")
        version = System.getProperty("java.version")
        log.info("Java version: " + version)
    except Exception as e:
        log.error("Error during reload: " + str(e))
  EOS
end

opennms_scriptd_script 'beanshell-event-threshold' do
  language 'beanshell'
  type 'event'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script <<-EOS
    log = bsf.lookupBean("log");
    String value = event.getParm("thresholdValue").getValue();
    log.info("Threshold exceeded with value: " + value);
    if (Integer.parseInt(value) > 90) {
      log.warn("CRITICAL: Value above 90!");
    }
  EOS
end

opennms_scriptd_script 'groovy-event-multiuei' do
  language 'groovy'
  type 'event'
  uei 'uei.opennms.org/cheftest/nodeDown,uei.opennms.org/cheftest/nodeUp'
  script <<-EOS
    def log = bsf.lookupBean("log")
    def uei = event.getUei()
    def node = event.getParm("nodeLabel")?.value ?: "unknown"
    log.info("Event received: ${uei} for node: ${node}")
    if (uei.contains("nodeDown")) {
      log.error("Node ${node} is DOWN!")
    } else {
      log.info("Node ${node} is UP.")
    }
  EOS
end

opennms_scriptd_script 'beanshell-event-multiuei' do
  language 'beanshell'
  type 'event'
  uei 'uei.opennms.org/cheftest/nodeDown,uei.opennms.org/cheftest/nodeUp'
  script <<-EOS
    log = bsf.lookupBean("log");
    String uei = event.getUei();
    String node = event.getParm("nodeLabel").getValue();
    log.info("Received UEI: " + uei + " for node: " + node);

    if (uei.contains("nodeDown")) {
      log.warn("ALERT: Node " + node + " is DOWN!");
    } else if (uei.contains("nodeUp")) {
      log.info("INFO: Node " + node + " is UP.");
    }
  EOS
end

opennms_scriptd_script 'groovy-event-interface' do
  language 'groovy'
  type 'event'
  uei 'uei.opennms.org/cheftest/interfaceDown,uei.opennms.org/cheftest/interfaceUp'
  script <<-EOS
    def log = bsf.lookupBean("log")
    def uei = event.getUei()
    def iface = event.getParm("interface")?.value ?: "unknown"
    log.info("Event received: ${uei} for interface: ${iface}")

    if (uei.contains("interfaceDown")) {
      log.error("Interface ${iface} is DOWN!")
    } else if (uei.contains("interfaceUp")) {
      log.info("Interface ${iface} is UP")
    }
  EOS
end

opennms_scriptd_script 'jython-event-service' do
  language 'jython'
  type 'event'
  uei 'uei.opennms.org/cheftest/serviceDown,uei.opennms.org/cheftest/serviceUp'
  script <<-EOS
    log = bsf.lookupBean("log")
    try:
        uei = event.getUei()
        svc = event.getParm("service").getValue()
        node = event.getParm("nodeLabel").getValue()
        log.info("UEI: " + uei + " | Service: " + svc + " | Node: " + node)

        if "serviceDown" in uei:
            log.error("Service " + svc + " is DOWN on " + node)
        elif "serviceUp" in uei:
            log.info("Service " + svc + " is UP on " + node)
    except Exception as e:
        log.error("Error handling event: " + str(e))
  EOS
end
