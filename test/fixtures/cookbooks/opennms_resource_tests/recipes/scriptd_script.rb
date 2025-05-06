opennms_scriptd_script 'beanshell' do
  language 'beanshell'
  script 'bsf.lookupBean("log")'
end

opennms_scriptd_script 'groovy' do
  language 'groovy'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script 'bsf.lookupBean("log")'
end
