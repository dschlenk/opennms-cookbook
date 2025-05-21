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

  describe scriptd_script('beanshell', 'start', 'bsf.lookupBean("log")') do
    it { should exist }
  end

  describe scriptd_script('groovy', 'stop', 'bsf.lookupBean("log")') do
    it { should exist }
  end

  describe scriptd_script('beanshell', 'event', 'bsf.lookupBean("log")', 'uei.opennms.org/cheftest/thresholdExceeded') do
    it { should exist }
  end
end
