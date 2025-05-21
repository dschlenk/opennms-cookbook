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

  describe scriptd_script('beanshell', 'start', 'bsf.lookupBean("log");') do
    it { should exist }
  end

  describe scriptd_script('groovy', 'stop', 'bsf.lookupBean("log")') do
    it { should exist }
  end

  describe scriptd_script('java', 'reload', 'bsf.lookupBean("log")') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'event', 'bsf.lookupBean("log")', 'uei.opennms.org/cheftest/thresholdExceeded') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'start', 'log = bsf.lookupBean("log"); log.info("Beanshell start script initialized."); String user = System.getProperty("user.name"); log.info("Running as user: " + user);') do
    it { should exist }
  end

  describe scriptd_script('groovy', 'stop', 'def log = bsf.lookupBean("log"); def now = new Date(); log.info("Groovy stop script executed at: ${now}"); if (now.hours > 18) { log.warn("Script stopped after hours."); }') do
    it { should exist }
  end

  describe scriptd_script('java', 'reload', 'log = bsf.lookupBean("log"); try { log.info("Reloading Java script."); String version = System.getProperty("java.version"); log.info("Java version: " + version); } catch (Exception e) { log.error("Error during reload: " + e.getMessage()); }') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'event', 'log = bsf.lookupBean("log"); String uei = event.getUei(); String node = event.getParm("nodeLabel").getValue(); log.info("Received UEI: " + uei + " for node: " + node); if (uei.contains("nodeDown")) { log.warn("ALERT: Node " + node + " is DOWN"); } else if (uei.contains("nodeUp")) { log.info("INFO: Node " + node + " is UP"); }', 'uei.opennms.org/cheftest/nodeDown,uei.opennms.org/cheftest/nodeUp') do
    it { should exist }
  end

  describe scriptd_script('groovy', 'event', 'def log = bsf.lookupBean("log"); def uei = event.getUei(); def iface = event.getParm("interface")?.value ?: "unknown"; log.info("Event received: ${uei} for interface: ${iface}"); if (uei.contains("interfaceDown")) { log.error("Interface ${iface} is DOWN"); } else if (uei.contains("interfaceUp")) { log.info("Interface ${iface} is UP"); }', 'uei.opennms.org/cheftest/interfaceDown,uei.opennms.org/cheftest/interfaceUp') do
    it { should exist }
  end
end
