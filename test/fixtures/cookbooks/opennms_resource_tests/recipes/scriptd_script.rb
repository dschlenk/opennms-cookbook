opennms_scriptd_script 'beanshell' do
  script ''
end

opennms_scriptd_script 'groovy' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script ''
end
