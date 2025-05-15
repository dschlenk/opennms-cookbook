opennms_scriptd_script 'beanshell-start' do
  language 'beanshell'
  type 'start'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'groovy-stop' do
  language 'groovy'
  type 'stop'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'jython-reload' do
  language 'jython'
  type 'reload'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'beanshell-event' do
  language 'beanshell'
  type 'event'
  script 'bsf.lookupBean("log")'
end
