opennms_avail_category 'beanshell' do
  script ''
end

opennms_avail_category 'groovy' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded'
  script ''
end
