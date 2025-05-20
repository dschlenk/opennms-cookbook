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
 
  describe scriptd_engine('jython') do
    it { should exist }
    its('class_name') { should eq 'org.python.util.PythonInterpreter' }
    its('extensions') { should eq 'py' }
  end
 
  describe scriptd_engine('java') do
    it { should exist }
    its('class_name') { should eq 'com.game.core.physics.CollisionManagerr' }
    its('extensions') { should eq 'java' }
  end
 
  describe scriptd_script('beanshell', 'start', 'log = bsf.lookupBean("log"); log.info("Beanshell start script initialized.");') do
    it { should exist }
  end
 
  describe scriptd_script('groovy', 'stop', 'def log = bsf.lookupBean("log"); def now = new Date(); log.info("Groovy stop script executed at: ${now}")') do
    it { should exist }
  end
 
  describe scriptd_script('jython', 'reload', 'log = bsf.lookupBean("log"); log.info("Reloading Jython script.")') do
    it { should exist }
  end
 
  describe scriptd_script('beanshell', 'event', 'log = bsf.lookupBean("log"); String value = event.getParm("thresholdValue").getValue(); log.info("Threshold exceeded with value: " + value);', 'uei.opennms.org/cheftest/thresholdExceeded') do
    it { should exist }
  end
 
  describe scriptd_script('groovy', 'event', 'def log = bsf.lookupBean("log"); def uei = event.getUei(); def node = event.getParm("nodeLabel")?.value ?: "unknown"; log.info("Event received: ${uei} for node: ${node}")', 'uei.opennms.org/cheftest/nodeDown,uei.opennms.org/cheftest/nodeUp') do
    it { should exist }
  end
 
  describe scriptd_script('jython', 'event', 'log = bsf.lookupBean("log"); uei = event.getUei(); svc = event.getParm("service").getValue(); node = event.getParm("nodeLabel").getValue(); log.info("UEI: " + uei + " | Service: " + svc + " | Node: " + node)', 'uei.opennms.org/cheftest/serviceDown,uei.opennms.org/cheftest/serviceUp') do
    it { should exist }
  end
end
