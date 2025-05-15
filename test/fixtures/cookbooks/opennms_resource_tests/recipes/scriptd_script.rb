opennms_scriptd_script 'beanshell' do
  language 'beanshell'
  type 'start'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'groovy' do
  language 'groovy'
  type 'stop'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'jython' do
  language 'jython'
  type 'reload'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'beanshell' do
  language 'beanshell'
  type 'event'
  script 'log = bsf.lookupBean("log")'
end
