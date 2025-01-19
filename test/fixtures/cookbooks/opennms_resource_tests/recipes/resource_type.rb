# typical usage - in a group
opennms_resource_type 'wibbleWobble' do
  group_name 'metasyntactic'
  label 'Wibble Wobble'
  resource_label '${wibble} - ${wobble}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end

# this will get created in the same file as the first one
opennms_resource_type 'wobbleWibble' do
  group_name 'metasyntactic'
  label 'Wobble Wibble'
  resource_label '${wobble} - ${wibble}'
end

# typical usage - in a resource-types.d file
opennms_resource_type 'newerType' do
  file_name 'newer-type.xml'
  label 'Newer Type'
  resource_label '${type} - ${name}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end

# delete an existing type - group style
# Note that the group name is actually the filename minus the file extension.
# Resource types created with the older version of this resource
# (that didn't use delayed initialized accumulator with a template)
# made a file named for the group_name + .xml,
# but it would search the whole directory for an existing group named the same first.
# We don't do that anymore.
# However, if a resource type was created as part of the export of a MIB by the MIB compiler
# or the resource type was created by the older iteration of this custom resource,
# the group name and the expected filename match.
# So, in most cases, this shouldn't be a problem for resource types that were added
# on top of the default types that ship with OpenNMS.
# But the vast majority of resource types that ship with OpenNMS are in files with groups where the name is at a minimum not the same case as the file name minus the extension.
# So to alter (update or delete) those, use the filename, minus the extension, for the group_name value
# instead of the actual group name.
opennms_resource_type 'wmiW3' do
  group_name 'wmi'
  action :delete
end

# delete an existing type - resource-types.d style
opennms_resource_type 'wmiCollector' do
  file_name 'wmi-collector.xml'
  action :delete
end

# update an existing type - group style
# note that group_file_name is needed since we are modifying a resource where the filename prefix and group name do not match
opennms_resource_type 'drsPSUIndex' do
  group_name 'Dell'
  group_file_name 'dell.xml'
  label 'Dell DRAC Power Supply Unit'
  resource_label 'Location: ${drsPSULocation}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end

# update an existing type - resource-types.d style
opennms_resource_type 'pgTableSpace' do
  file_name 'postgresql-resource.xml'
  label 'PG Tablespace'
  resource_label 'space ${spcname}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end

# create if missing
opennms_resource_type 'create_if_missing' do
  group_name 'metasyntactic'
  label 'Create If Missing'
  resource_label '${resource} (index:${index})'
  action :create_if_missing  # Ensures creation if missing
end

# noop create if missing
opennms_resource_type 'noop_create_if_missing' do
  group_name 'metasyntactic'
  label 'Noop Create If Missing'
  resource_label '${resource} (index:${index})'
  action :create_if_missing
  only_if { false }
end

