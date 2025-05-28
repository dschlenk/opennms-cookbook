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

  describe scriptd_script('beanshell', 'event', 'bsf.lookupBean("log");', 'uei.opennms.org/cheftest/thresholdExceeded') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'start', "log = bsf.lookupBean(\"log\");\nlog.info(\"Beanshell start script initialized.\");\nString user = System.getProperty(\"user.name\");\nlog.info(\"Running as user: \" + user);") do
    it { should exist }
  end

  describe scriptd_script('groovy', 'stop', "def log = bsf.lookupBean(\"log\"); def now = new Date(); log.info(\"Groovy stop script executed at: ${now}\"); if (now.hours > 18) { log.warn(\"Script stopped after hours.\"); }") do
    it { should exist }
  end

  describe scriptd_script('java', 'reload', "log = bsf.lookupBean(\"log\");\ntry { log.info(\"Reloading Java script.\");\nString version = System.getProperty(\"java.version\");\nlog.info(\"Java version: \" + version);\n}\ncatch (Exception e) {\nlog.error(\"Error during reload: \" + e.getMessage());\n}") do
    it { should exist }
  end
end
