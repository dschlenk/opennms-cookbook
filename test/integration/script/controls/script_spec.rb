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

  describe scriptd_script('beanshell') do
    it { should exist }
    its('language') { should eq 'beanshell' }
    its('type') { should eq 'start' }
    its('script') { should eq 'bsf.lookupBean("log")' }
  end

  describe scriptd_script('groovy') do
    it { should exist }
    its('language') { should eq 'groovy' }
    its('type') { should eq 'stop' }
    its('uei') { should eq 'uei.opennms.org/cheftest/thresholdExceeded' }
    its('script') { should eq 'bsf.lookupBean("log")' }
  end

  describe scriptd_script('jython') do
    it { should exist }
    its('language') { should eq 'jython' }
    its('type') { should eq 'reload' }
    its('uei') { should eq 'uei.opennms.org/cheftest/thresholdExceeded' }
    its('script') { should eq 'bsf.lookupBean("log")' }
  end

  describe scriptd_script('beanshell') do
    it { should exist }
    its('language') { should eq 'beanshell' }
    its('type') { should eq 'event' }
    its('script') { should eq 'bsf.lookupBean("log")' }
  end
end
