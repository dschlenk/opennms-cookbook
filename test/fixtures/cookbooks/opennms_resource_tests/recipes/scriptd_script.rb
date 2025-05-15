opennms_scriptd_script 'beanshell' do
  type 'start'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'groovy' do
  type 'stop'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'jython' do
  type 'reload'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'beanshell' do
  type 'event'
  script 'log = bsf.lookupBean(\"log\")'
end
