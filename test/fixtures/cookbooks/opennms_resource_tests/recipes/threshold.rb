include_recipe 'opennms_resource_tests::threshold_common'
# common options
opennms_threshold 'icmp' do
  group 'cheftest'
  type 'high'
  description 'ping latency too high'
  ds_type 'if'
  value 20_000.0
  rearm 18_000.0
  trigger 2
  notifies :run, 'opennms_send_event[restart_Thresholds]'
end

# lots o' options
opennms_threshold 'espresso' do # name is ds-name, and is part of identity
  group 'coffee' # part of identity
  type 'low' # part of identity
  ds_type 'if' # part of identity
  description 'alarm when percentage of espresso in bloodstream too low'
  value 50.0
  rearm 60.0
  trigger 3
  ds_label 'bloodEspressoContent'
  triggered_uei 'uei.opennms.org/thresholdTrigger'
  rearmed_uei 'uei.opennms.org/thresholdRearm'
  filter_operator 'and' # part of identity
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }] # part of identity
end
