opennms_scriptd_script 'beanshell' do
  language 'beanshell'
  script ''
end

opennms_scriptd_script 'groovy' do
  language 'groovy'
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script ''
end
