opennms_scriptd_script 'beanshell' do
  language 'beanshell'
  script 'System.out.println("beanshell script running");'
end

opennms_scriptd_script 'groovy' do
  language 'groovy'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'System.out.println("groovy script running");'
end
