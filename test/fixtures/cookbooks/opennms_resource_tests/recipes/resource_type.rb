# frozen_string_literal: true
# typical usage
opennms_resource_type 'wibbleWobble' do
  group_name 'metasyntactic'
  label 'Wibble Wobble'
  resource_label '${wibble} - ${wobble}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params [{ 'theKey' => 'theValue' }]
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params [{ 'theKey' => 'theValue' }]
end

# even though the group_name is different, this one won't get created because resourceTypes are global
opennms_resource_type 'wibbleWobble' do
  group_name 'garbage'
  label 'Wobbles'
  resource_label 'wibble ${wobble}'
end

# this will get created in the same file as the first one
opennms_resource_type 'wobbleWibble' do
  group_name 'metasyntactic'
  label 'Wobble Wibble'
  resource_label '${wobble} - ${wibble}'
end
