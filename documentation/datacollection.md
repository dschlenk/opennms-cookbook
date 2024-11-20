# Data Collection Resources

Data collection in OpenNMS can be performed through a number of protocols, like SNMP, JDBC, JMX, XML/JSON via HTTP, etc.
Collection is performed against services present on interfaces when that interface matches the criteria of a collection package that the service is a part of.
There are custom resources available to manage packages and services in `collectd-configuration.xml`, and protocol-specific resources for managing the `datacollection-config` files.
All resources use the initialized delayed accumulator pattern, so template variables are created in accordance with current state when the first resource is executed, and the execution of all subsequent resource instances that affect that file simply modify those template variables, and the template action is then executed at the end of the run once all variables are finalized.
The templates are then rendered at the conclusion of the run as delayed `:create` actions.
Appropriate service restarts are performed automatically.

## Packages and Services

### opennms\_collection\_package

Manages a `package` in `collectd`.

#### Actions for opennms\_collection\_packaga

* `:create` - Default. Adds or updates a `package` element in the file with the name matching the `package_name` property.
* `:update` - Modify an existing `package` element. Raises an error if the package does not exist.
* `:delete` - Remove an existing `package` element and its children if it exists.

#### Properties for opennms\_collection\_packaga

| Name                 | Name? | Type                  | Allowed Values                                                                    |
| -------------------- | ----- | --------------------- | --------------------------------------------------------------------------------- |
| `package_name`       |   ✓   | String                |                                                                                   |
| `filter`             |       | String                |                                                                                   |
| `specifics`          |       | Array                 | array of Strings                                                                  |
| `include_ranges`     |       | Array                 | array of Strings                                                                  |
| `exclude_ranges`     |       | Array                 | array of Strings                                                                  |
| `include_urls`       |       | Array                 | array of Strings                                                                  |
| `outage_calendars`   |       | Array                 | array of Strings                                                                  |
| `store_by_if_alias`  |       | [true, false]         |                                                                                   |
| `store_by_node_id`   |       | [String, true, false] |                                                                                   |
| `if_alias_domain`    |       | String                |                                                                                   |
| `stor_flag_override` |       | [true, false]         |                                                                                   |
| `if_alias_comment`   |       | String                |                                                                                   |
| `remote`             |       | [true, false]         |                                                                                   |

#### Examples for opennms\_collection\_packaga

The `default_resources` recipe contains the packages that ship with OpenNMS. For instance:

```ruby
opennms_collection_package 'cassandra-via-jmx' do
  filter "IPADDR != '0.0.0.0'"
  remote false
end
```

will result in the package:

```xml
<package name="cassandra-via-jmx" remote="false">
    <filter>IPADDR != '0.0.0.0'</filter>
    ...
</package>
```

and

```ruby
opennms_collection_package 'example1' do
  filter "IPADDR != '0.0.0.0'"
  remote false
  include_ranges [
    { 'begin' => '1.1.1.1', 'end' => '254.254.254.254' },
    { 'begin' => '::1', 'end' => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' },
  ]
end
```

creates

```xml
<package name="example1" remote="false">
    <filter>IPADDR != '0.0.0.0'</filter>
    <include-range begin="1.1.1.1" end="254.254.254.254" />
    <include-range begin="::1" end="ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff" />
</package>
```

### opennms\_collection\_service

Manages `service` elements in a `package` and the corresponding `collector` element in `collectd-configuration.xml`.

#### Actions for opennms\_collection\_service

* `:create` - Default. Adds or updates a `service` element in the file with the name matching `service_name` and `package_name` properties.
* `:update` - Modify an existing `service` and `collector` element. Raises an error if either do not exist.
* `:delete` - Remove an existing `service` and `collector` elements and their children if it exists.

#### Properties for opennms\_collection\_service

| Name                   | Name? | Type                | Validation / Usage Notes                                     |
| ---------------------- | ----- | ------------------- | ------------------------------------------------------------ |
| `service_name`         |   ✓   | String              |                                                              |
| `package_name`         |       | String              | defaults to `example1`; part of identity                     |
| `class_name`           |       | String              |                                                              |
| `interval`             |       | Integer             | defaults to `300000` for action `:create`                    |
| `user_defined`         |       | true, false         | `true` or `false`; defaults to `false` for action `:create`  |
| `status`               |       | String              | `on` or `off`; defaults to `on` for action `:create`         |
| `timeout`              |       | String, Integer     | should be a metadata expression when not an Integer          |
| `port`                 |       | String, Integer     | should be a metadata expression when not an Integer          |
| `parameters`           |       | Hash                | should be a hash with key/value pairs that are both strings  |
| `class_parameters`     |       | Hash                | should be a hash with key/value pairs that are both strings  |
| `collection`           |       | String              | defaults to `default`                                        |
| `retry_count`          |       | String, Integer     | should be a metadata expression when not an Integer          |
| `thresholding_enabled` |       | true, false, String | should be a metadata expression when not `true` or `false`   |

Many of the properties listed are rendered as `parameter` elements in the resulting `service` element, including `timeout`, `port`, `collection`, `retry_count`, and `thresholding_enabled`. If the value is present as a property as well as a value in the `parameters` hash, the value in the property takes precedence.

`class_parameters` are parameters added to the corresponding `collector` element with `class-name` matching `class_name`.

#### Examples for opennms\_collection\_service

Recipe [default\_collection\_packages.rb](../recipes/default_collection_packages.rb) manages the default collection packages that ship with OpenNMS.
For instance:

```ruby
opennms_collection_service 'VMware-VirtualMachine' do
  package_name 'vmware7'
  class_name 'org.opennms.netmgt.collectd.VmwareCollector'
  collection '${requisition:collection|detector:collection|default-VirtualMachine7}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end
```

adds two elements to `collectd-configuration.xml`.
To the `package` with name `vmware7`, the following element is added:

```xml
<service name="VMware-VirtualMachine" interval="300000" user-defined="false" status="on">
   <parameter key="collection" value="${requisition:collection|detector:collection|default-VirtualMachine7}" />
   <parameter key="thresholding-enabled" value="true" />
</service>
```

and the `collector`:

```xml
<collector service="VMware-VirtualMachine" class-name="org.opennms.netmgt.collectd.VmwareCollector" />
```

### opennms\_resource\_type

Manages `resourceType` elements in either a `datacollection-group` file in `$OPENNMS_HOME/etc/datacollection/` or a `resource-types` file in `$OPENNMS_HOME/etc/resource-types.d/`.

### Actions for opennms\_resource\_type

* `:create` - Default. Adds or updates a `resourceType` element in the file indicated by the resource properties.
* `:update` - Modify an existing `resourceType` element according to the property values provided in the resource. Properties not specified in the resource are left unchanged. Raises an exception if the resource does not exist.
* `:delete` - Remove an existing `resourceType` element in the file indicated by the resource properties if it exists.

### Properties for opennms\_resource\_type

| Name                                   | Name? | Type    | Validation / Usage Notes                                                                            |
| -------------------------------------- | ----- | ------- | --------------------------------------------------------------------------------------------------- |
| `type_name`                            |   ✓   | String  |                                                                                                     |
| `group_name`                           |       | String  | Use to manage a `resourceType` in a `datacollection-group` file                                     |
| `file_name`                            |       | String  | Use to manage a `resourceType` in a `resource-types` file                                           |
| `label`                                |       | String  | Required for `:create` action                                                                       |
| `resource_label`                       |       | String  | Defaults to `${resource} (index:${index})` for action `:create`                                     |
| `persistence_selector_strategy`        |       | String  | Defaults to `org.opennms.netmgt.collection.support.PersistAllSelectorStrategy` for action `:create` |
| `persistence_selector_strategy_params` |       | Hash    | Must be a Hash of String key value pairs                                                            |
| `storage_strategy`                     |       | String  | Defaults to `org.opennms.netmgt.collection.support.IndexStorageStrategy` for action `:create`       |
| `storage_strategy_params`              |       | Hash    | Must be a Hash of String key value pairs                                                            |

You must specify either `group_name` or `file_name`. If both are specified, `group_name` is used.

#### `datacollection-group` Resource Types

When `group_name` is present, the managed `resourceType` will be in file `$OPENNMS_HOME/etc/datacollection/<group_name>.xml` and the root element will be `datacollection-group`.
For existing files, if the name attribute of the `datacollection-group` differs from the provided `group_name`, the existing value will be preserved.
For new files, the name attribute of the `datacollection-group` element will match `group_name`.
If the name of the group in the file is not already included by the `default` SNMP collection in `$OPENNMS_HOME/etc/datacollection-config.xml`, it will be added automatically.

#### `resource-types` Resource Types

When `group_name` is not present but `file_name` is, the managed resource type will be present in `$OPENNMS_HOME/etc/resource-types.d/<file_name>` and the root element will be `resource-types`.

### Examples for opennms\_resource\_type

Create a resource type in a `datacollection-group` named `metasyntactic` in file `$OPENNMS_HOME/etc/datacollection/metasyntactic.xml`:

```ruby
opennms_resource_type 'wibbleWobble' do
  group_name 'metasyntactic'
  label 'Wibble Wobble'
  resource_label '${wibble} - ${wobble}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end
```

Doing the same in a `resource-types` file in `$OPENNMS_HOME/etc/resource-types.d`:

```ruby
opennms_resource_type 'wibbleWobble' do
  file_name 'metasyntactic.xml'
  label 'Wibble Wobble'
  resource_label '${wibble} - ${wobble}'
  persistence_selector_strategy 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy'
  persistence_selector_strategy_params('theKey' => 'theValue')
  storage_strategy 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy'
  storage_strategy_params('theKey' => 'theValue')
end
```

See the [resource\_type.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/resource_type.rb) test fixture recipe and [integration\ tests](../test/integration/resource_type/controls/resource_type_spec.rb) for more examples.

## SNMP

Along with the protocol agnostic resources above, the resources `opennms_snmp_collection`, `opennms_snmp_collection_group`, `opennms_snmp_collection_service`, and `opennms_system_def` are available to manage SNMP data collection.

### opennms\_snmp\_collection\_service

A convenience wrapper of [`opennms_collection_service`](#opennms_collection_service) that automatically sets the `class_name` property to `org.opennms.netmgt.collectd.SnmpCollector`.

### `opennms_snmp_collection`

Manages an `snmp-collection` in `$OPENNMS_HOME/etc/datacollection-config.xml`.

#### Actions for opennms\_snmp\_collection\_service

* `:create` - Default. Adds or updates a `snmp-collection` element in `$OPENNMS_HOME/etc/datacollection-config.xml`.
* `:update` - Modify an existing `snmp-collection` element according to the property values provided in the resource. Properties not specified in the resource are left unchanged. Raises an exception if the resource does not exist.
* `:delete` - Remove an existing `snmp-collection` element if it exists.

#### Properties for opennms\_snmp\_collection\_service

| Name                  | Name? | Type    | Allowed Values                                          |
| --------------------- | ----- | ------- | ------------------------------------------------------- |
| `collection`          |   ✓   | String  |                                                         |
| `rrd_step`            |       | Integer |                                                         |
| `rras`                |       | Array   | an array of strings that match regular expression below |
| `max_vars_per_pdu`    |       | Integer |                                                         |
| `snmp_stor_flag`      |       | String  | `all` `select` `primary`                                |
| `include_collections` |       | Array   | array of hashes  (see below for validation specifics)   |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified. Each must match regular expression `RRA:(AVERAGE\|MIN\|MAX\|LAST):.*`.

`max_vars_per_pdu` is deprecated by OpenNMS and its use is discouraged

`snmp_stor_flag` defaults to `select` on `:create`

`include_collections` should be an array of hashes with keywords `:data_collection_group` (string, required), `:exclude_filters` (array of strings, optional), `:system_def` (string, optional).

#### Examples for opennms\_snmp\_collection\_service

The [default\_snmp\_resources.rb](../recipes/default_snmp_resources.rb) recipe includes an opennms\_snmp\_collection resource named `default` that manages the `default` SNMP collection.

See the [snmp\_collection.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_collection.rb) test fixture recipe and [integration\ tests](../test/integration/snmp_collection/controls/snmp_collection_spec.rb) for more examples.

### opennms\_snmp\_collection\_group

Manages a file in `$OPENNMS_HOME/etc/datacollection/` and inclusion of the group defined in that file in an SNMP collection.

#### Actions for opennms\_snmp\_collection\_group

* `:create` - Default. Creates or updates a `datacollection-group` file in `$OPENNMS_HOME/etc/datacollection/` and includes it in the specified collection..
* `:update` - Modify an existing file or how the group is included in the collection. Raises an error if the group does not exist.
* `:delete` - Remove an existing file and the reference to the group contained therein from the specified collection if it exists.

#### Properties for opennms\_snmp\_collection\_group

| Name              | Name? | Type    | Allowed Values                                                                    |
| ----------------- | ----- | ------- | --------------------------------------------------------------------------------- |
| `group_name`      |   ✓   | String  |                                                                                   |
| `collection_name` |       | String  | An existing `snmp-collection` in `datacollection-config.xml`.                     |
| `file`            |       | String  |                                                                                   |
| `source`          |       | String  |                                                                                   |
| `system_def`      |       | String  | array of hashes  (see below for validation specifics)                             |
| `exclude_filters` |       | Array   | array of hashes  (see below for validation specifics)                             |

`group_name` is the name of the group to include in the `snmp-collection` with name `collection_name` in `$OPENNMS/etc/datacollection-config.xml`. It must be defined in the file indicated by the properties of this resource.

`collection_name` an existing `snmp-collection` in `$OPENNMS_HOME/etc/datacollection-config.xml`.

`file` the name of the file to deploy to `$OPENNMS_HOME/etc/datacollection` containing the `datacollection-group` definition that this resource manages (which must be present in the cookbook defining this resource) when `source` is set to `cookbook_file` (the default).

`source` the URL to a valid `datacollection-group` file to be deployed to `OPENNMS_HOME/etc/datacollection` or `cookbook_file` (default) to indicate that the file to deploy is present in the cookbook that defines this resource.

`system_def` a system definition name present in the file to explicitly include in this collection with this group

`exclude_filters` one or more regular expression strings indicating system definitions to not include in the collection with the inclusion of this group

#### Examples for opennms\_snmp\_collection\_group

See the [snmp\_collection\_group.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_collection_group.rb) test fixture recipe and [integration\ tests](../test/integration/snmp_collection_group/controls/snmp_collection_group_spec.rb) for examples of action `:create`.

See the [snmp\_collection\_group\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_collection_group_delete.rb) test fixture recipe and [integration\ tests](../test/integration/snmp_collection_group_delete/controls/snmp_collection_group_delete_spec.rb) for examples of action `:delete`.

See the [snmp\_collection\_group\_edit.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/snmp_collection_group_edit.rb) test fixture recipe and [integration\ tests](../test/integration/snmp_collection_group_edit/controls/snmp_collection_group_spec.rb) for examples of action `:edit`.

### opennms\_system\_def

Manages `systemDef` elements in a `datacollection-group` file in `$OPENNMS_HOME/etc/datacollection/`.

#### Actions for opennms\_system\_def

* `:add` - Add one or more groups to an existing `systemDef`.
* `:remove` - Remove one or more groups from an existing `systemDef`.
* `:create` - Create a new `systemDef`, potentially in a new file.
* `:update` - Update an existing `systemDef` to match the properties provided in the resource.
* `:delete` - Remove the `systemDef` with matching `system_name` from the file identified by the `file_name` property if it exists.

#### Properties for opennms\_system\_def

| Property      | Name? | Type   | Identity? | Validation / Usage Notes                                  |
| ------------- | ----- | ------ | --------- | --------------------------------------------------------- |
| `system_name` |   ✓   | String |     ✓     |                                                           |
| `file_name`   |       | String |     ✓     | required                                                  |
| `sysoid`      |       | String |           | required when `sysoid_mask` is nil                        |
| `sysoid_mask` |       | String |           | required when `sysoid` is nil                             |
| `groups`      |       | Array  |           | should be an array of strings referencing existing groups |

#### Examples for opennms\_system\_def

See the [system\_def.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/system_def.rb) test fixture recipe and [integration\ tests](../test/integration/system_def/controls/system_def_spec.rb) for examples.

## JDBC

To manage JDBC data collection, use the following resources: `opennms_jdbc_collection`, `opennms_jdbc_query`, and `opennms_jdbc_collection_service`.

### opennms\_jdbc\_collection\_service

A convenience wrapper of [`opennms_collection_service`](#opennms_collection_service) that automatically sets the `class_name` property to `org.opennms.netmgt.collectd.JdbcCollector`. It also allows you to deploy a JDBC driver file to `$OPENNMS_HOME/lib/`.

#### Properties for opennms\_jdbc\_collection\_service

The following extra properties are available to `opennms_jdbc_collection_service` along with those provided by the protocol agnostic resource `opennms_collection_service`.

| Property      | Type   | Parameter? |
| ------------- | ------ | ---------- |
| `password`    | String |     ✓      |
| `url`         | String |     ✓      |
| `driver`      | String |     ✓      |
| `driver_file` | String |            |
| `user`        | String |     ✓      |

Properties marked as a parameter are rendered as `parameter` elements.

`driver_file` should be the name of a jar file in the cookbook that defines this resource. It will be deployed to `$OPENNMS_HOME/lib`.

#### Examples for opennms\_jdbc\_collection\_service

See the [jdbc\_collection\_service.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection_service.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection_service/controls/jdbc_collection_service_spec.rb) for examples of action `:create`.

See the [jdbc\_collection\_service\_edit.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection_service_edit.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection_service_edit/controls/jdbc_collection_service_edit_spec.rb) for examples of action `:edit`.

See the [jdbc\_collection\_service\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection_service_edit.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection_service_delete/controls/jdbc_collection_service_noop_spec.rb) for examples of action `:delete`.

### opennms\_jdbc\_collection

Manages a `jdbc-collection` in `$OPENNMS_HOME/etc/jdbc-datacollection-config.xml`.

#### Actions for opennms\_jdbc\_collection

* `:create` - Default. Adds or updates a `jdbc-collection` element in `$OPENNMS_HOME/etc/jdbc-datacollection-config.xml`.
* `:update` - Modify an existing `jdbc-collection` element according to the property values provided in the resource. Properties not specified in the resource are left unchanged. Raises an exception if the resource does not exist.
* `:delete` - Remove an existing `jdbc-collection` element if it exists.

#### Properties for opennms\_jdbc\_collection

| Name                  | Name? | Type    | Allowed Values                                                |
| --------------------- | ----- | ------- | ------------------------------------------------------------- |
| `collection`          |   ✓   | String  |                                                               |
| `rrd_step`            |       | Integer |                                                               |
| `rras`                |       | Array   | an array of strings that match regular expression found below |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified. Each must match regular expression `RRA:(AVERAGE\|MIN\|MAX\|LAST):.*`.

#### Examples for opennms\_jdbc\_collection

The [default\_jdbc\_resources.rb](../recipes/default_jdbc_resources.rb) recipe includes an `opennms_jdbc_collection` resource named `default` that manages the `default` SNMP collection.

See the [jdbc\_collection.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection/controls/jdbc_collection_spec.rb) for more examples of action `:create`.

See the [jdbc\_collection\_edit.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection_edit.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection_edit/controls/jdbc_collection_spec.rb) for examples of action `:edit`.

See the [jdbc\_collection\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_collection_delete.rb) test fixture recipe and [integration\ tests](../test/integration/jdbc_collection_delete/controls/jdbc_collection_spec.rb) for examples of action `:delete`.

### opennms\_jdbc\_query

Manages `query` elements in the specified `jdbc-collection`.

#### Actions for opennms\_jdbc\_query

* `:create` - Default. Adds the `query` element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `query` element and its children. Raises an error if the `query` does not exist.
* `:delete` - Deletes the referenced `query` element and its children if it exists.

#### Properties for opennms\_jdbc\_query

| Name                   | Name? | Type    | Identity? | Required? |
| ---------------------- | ----- | --------| --------- | --------- |
| `query_name`           |   ✓   | String  |     ✓     |     ✓     |
| `collection_name`      |       | String  |     ✓     |     ✓     |
| `if_type`              |       | String  |           |     ✓     |
| `recheck_interval`     |       | Integer |           |     ✓     |
| `resource_type`        |       | String  |           |           |
| `instance_column`      |       | String  |           |           |
| `query_string`         |       | String  |           |           |
| `columns`              |       | Hash    |           |           |

The `collection_name` must reference an existing collection (see the `jdbc_collection` resource above).

`columns` defines the values to collect from the query and should be a Hash where each key is a string that has a Hash value with required keys `alias` (string), `type` (string) and optional key `data-source-name` (string).

#### Examples for opennms\_jdbc\_query

See [jdbc\_query.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_query.rb), [jdbc\_query\_edit.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_query_edit.rb) and [jdbc\_query\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jdbc_query_delete.rb).

## JMX

To manage JMX data collection, use the following resources: `opennms_jmx_collection`, `opennms_jmx_mbean`, and `opennms_jmx_collection_service`.

### opennms\_jmx\_collection\_service

A convenience wrapper of [`opennms_collection_service`](#opennms_collection_service) that automatically sets the `class_name` property to `org.opennms.netmgt.collectd.Jsr160Collector`.

#### Properties for opennms\_jmx\_collection\_service

The following extra properties are available to `opennms_jdbc_collection_service` along with those provided by the protocol agnostic resource `opennms_collection_service`.

| Property          | Type   | Parameter? | Deprecated? |
| ----------------- | ------ | ---------- | ----------- |
| `password`        | String |     ✓      |             |
| `url`             | String |     ✓      |             |
| `factory`         | String |     ✓      |             |
| `protocol`        | String |     ✓      |      ✓      |
| `username`        | String |     ✓      |             |
| `url_path`        | String |     ✓      |      ✓      |
| `rmi_server_port` | String |     ✓      |      ✓      |
| `remote_jmx`      | String |     ✓      |      ✓      |
| `port`            | String |     ✓      |      ✓      |
| `rrd_base_name`   | String |     ✓      |             |
| `ds_name`         | String |     ✓      |             |
| `friendly_name`   | String |     ✓      |             |

Properties marked as a parameter are rendered as `parameter` elements. Items marked deprecated are ignored when `url` is present.

### opennms\_jmx\_collection

Manages a `jmx-collection` in `$OPENNMS_HOME/etc/jmx-datacollection-config.xml`.

#### Actions for opennms\_jmx\_collection

* `:create` - Default. Adds or updates a `jmx-collection` element in `$OPENNMS_HOME/etc/jmx-datacollection-config.xml`.
* `:update` - Modify an existing `jmx-collection` element according to the property values provided in the resource. Properties not specified in the resource are left unchanged. Raises an exception if the resource does not exist.
* `:delete` - Remove an existing `jmx-collection` element if it exists.

#### Properties for opennms\_jmx\_collection

| Name                  | Name? | Type    | Allowed Values                                                |
| --------------------- | ----- | ------- | ------------------------------------------------------------- |
| `collection`          |   ✓   | String  |                                                               |
| `rrd_step`            |       | Integer |                                                               |
| `rras`                |       | Array   | an array of strings that match regular expression found below |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified. Each must match regular expression `RRA:(AVERAGE\|MIN\|MAX\|LAST):.*`.

#### Examples for opennms\_jmx\_collection

The [default\_jmx\_resources.rb](../recipes/default_jmx_resources.rb) recipe includes an `opennms_jmx_collection` resource named `jsr160` that manages the `jsr160` SNMP collection.

See the [jmx.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jmx.rb) test fixture recipe and [integration\ tests](../test/integration/jmx/controls/jmx_spec.rb) for more examples.

### opennms\_jmx\_mbean

Manages `mbean` elements in  `jmx-collection` specified by property `collection_name` in `$OPENNMS_HOME/etc/jmx-datacollection-config.xml`.

#### Actions for opennms\_jmx\_mbean

* `:create` - Default. Adds the `mbean` element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `mbean` element and its children. Raises an error if the `mbean` does not exist.
* `:delete` - Deletes the referenced `mbean` element and its children if it exists.

#### Properties for opennms\_jmx\_mbean

| Name                   | Name? | Type    | Identity? | Required? |
| ---------------------- | ----- | --------| --------- | --------- |
| `mbean_name`           |   ✓   | String  |     ✓     |     ✓     |
| `collection_name`      |       | String  |     ✓     |     ✓     |
| `objectname`           |       | String  |     ✓     |     ✓     |
| `keyfield`             |       | String  |           |           |
| `exclude`              |       | String  |           |           |
| `key_alias`            |       | String  |           |           |
| `resource_type`        |       | String  |           |           |
| `attribs`              |       | Hash    |           |           |
| `include_mbeans`       |       | Array   |           |           |
| `comp_attribs`         |       | Hash    |           |           |

The `collection_name` must reference an existing collection (see the `opennms_jmx_collection` resource).

`attribs` and `comp_attribs` define the values to collect from the mbean.
`attribs` should be a Hash with string keys that represent the name field of each attrib and the value is a Hash with keys `alias` (string, required), `type` (string matching regex `([Cc](ounter|OUNTER)(32|64)?|[Gg](auge|AUGE)(32|64)?|[Tt](ime|IME)[Tt](icks|ICKS)|[Ii](nteger|NTEGER)(32|64)?|[Oo](ctet|CTET)[Ss](tring|TRING))`, required), `maxval` (string, optional), `minval` (string, optional).
`comp_attribs` should be a Hash with string keys that represent the name field of each comp-attrib and the value is a Hash with key `type` (a String matching `\[Cc](omposite|OMPOSITE)`, required),  `comp_members` (a Hash where the key (a String) is the name of the comp-member and the value is in the same format as the `attribs` hash values except `alias` is optional), and optional key `alias` (String).

`include_mbeans` should be an array of strings that each reference the name of another `mbean`.

#### Examples for opennms\_jmx\_mbean

The [default\_jmx\_resources.rb](../recipes/default_jmx_resources.rb) recipe includes an `opennms_jmx_collection` resource named `jsr160` that manages the `jsr160` SNMP collection.

See the [jmx.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/jmx.rb) test fixture recipe and [integration\ tests](../test/integration/jmx/controls/jmx_spec.rb) for more examples.

## WS-Man

To manage WS-Man data collection, use the following resources: `opennms_wsman_collection`, `opennms_wsman_group`, `opennms_wsman_system_definition`, and `opennms_wsman_collection_service`.

### opennms\_wsman\_collection\_service

A convenience wrapper of [`opennms_collection_service`](#opennms_collection_service) that automatically sets the `class_name` property to `org.opennms.netmgt.collectd.WsManCollector`.

### opennms\_wsman\_collection

Manages an `wsman-collection` in `$OPENNMS_HOME/etc/wsman-datacollection-config.xml`.

#### Actions for opennms\_wsman\_collection

* `:create` - Default. Adds or updates a `collection` element in `$OPENNMS_HOME/etc/wsman-datacollection-config.xml`.
* `:update` - Modify an existing `collection` element according to the property values provided in the resource. Properties not specified in the resource are left unchanged. Raises an exception if the resource does not exist.
* `:delete` - Remove an existing `collection` element if it exists.

#### Properties for opennms\_wsman\_collection

| Name                         | Name? | Type                | Allowed Values                                          |
| ---------------------------- | ----- | ------------------- | ------------------------------------------------------- |
| `collection`                 |   ✓   | String              |                                                         |
| `rrd_step`                   |       | Integer             |                                                         |
| `rras`                       |       | Array               | an array of strings that match regular expression below |
| `include_system_definitions` |       | String, true, false | true, false, "true", "false"                            |
| `include_system_definition`  |       | Array               | array of strings                                        |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified. Each must match regular expression `RRA:(AVERAGE\|MIN\|MAX\|LAST):.*`.

`include_system_definitions` whether or not to include all system definitions in this collection

`include_system_definition` a list of system definitions by name to include in this collection

#### Examples for opennms\_wsman\_collection

See the [wsman\_collection.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/wsman_collection.rb) test fixture recipe and [integration\ tests](../test/integration/wsman_collection/controls/wsman_collection_spec.rb) for more examples.

### opennms\_wsman\_group

Manages a group element in `file_name` inside `$OPENNMS_HOME/etc/` or `$OPENNMS_HOME?etc/wsman-datacollection-config.xml`.

#### Actions for opennms\_wsman\_group

* `:create` - Default. Adds the element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `group` element and its children. Raises an error if the `group` does not exist.
* `:delete` - Deletes the referenced `group` element and its children if it exists.

#### Properties for opennms\_wsman\_group

| Name               | Name? | Type            | Identity? | Required?  |
| ------------------ | ----- | --------------- | --------- | ---------- |
| `group_name`       |   ✓   | String          |     ✓     |     ✓      |
| `file_name`        |       | String          |     ✓     |            |
| `resource_type`    |       | String          |           | on :create |
| `resource_uri`     |       | String          |           | on :create |
| `dialect`          |       | String          |           |            |
| `filter`           |       | String          |           |            |
| `attribs`          |       | Array           |           |            |

When the `file_name` property is set, the group is added to a file in `$OPENNMS_HOME/etc/<file>`. Otherwise the group is added to the main config file.

The validation on `attribs` ensures that it is an array of hashes with the following required string keys with string values: `name`, `alias`, `type` (matches `([Cc](ounter|OUNTER)|[Gg](auge|AUGE)|[Ss](tring|TRING))`) and the following optional string keys with string values: `index-of`, `filter`.

#### Examples for opennms\_wsman\_group

See the [wsman\_group.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/wsman_group.rb) test fixture recipe and [integration\ tests](../test/integration/wsman_group/controls/wsman_group_spec.rb) for examples.

### opennms\_wsman\_system\_definition

Manages `system-definition` elements in a `wsman-datacollection-config` file in `$OPENNMS_HOME/etc/`.

#### Actions for opennms\_wsman\_system\_definition

* `:add` - Add one or more groups to an existing `system-definition`.
* `:remove` - Remove one or more groups from an existing `system-definition`.
* `:create` - Create a new `system-definition`, potentially in a new file.
* `:update` - Update an existing `system-definition` to match the properties provided in the resource.
* `:delete` - Remove the `system-definition` with matching `system_name` from the file identified by the `file_name` property if it exists.

#### Properties for opennms\_wsman\_system\_definition

| Property      | Name? | Type   | Identity? | Validation / Usage Notes                                  |
| ------------- | ----- | ------ | --------- | --------------------------------------------------------- |
| `system_name` |   ✓   | String |     ✓     |                                                           |
| `file_name`   |       | String |     ✓     |                                                           |
| `rule`        |       | String |           | required for `:create`                                    |
| `groups`      |       | Array  |           | should be an array of strings referencing existing groups |

#### Examples for opennms\_wsman\_system\_definition

See the [wsman\_system\_definition.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/wsman_system_definition.rb) test fixture recipe and [integration\ tests](../test/integration/wsman_system_definition/controls/wsman_system_definition_spec.rb) for examples.

## XML

The following resources are available to express XML data collection configuration as code.

### opennms\_xml\_collection\_service

A convenience wrapper of [`opennms_collection_service`](#opennms_collection_service) that automatically sets the `class_name` property to `org.opennms.protocols.xml.collector.XmlCollector`.

### opennms\_xml\_collection

Manages an `xml-collection` element in `$OPENNMS_HOME/etc/xml-datacollection-config.xml`.

#### Actions for opennms\_xml\_collection

* `:create` - Default. Adds or updates the `xml-collection` element in the file with the name matching the `collection` property.
* `:update` - Modify an existing `xml-collection` element. Raises an error if the collection does not exist.
* `:delete` - Remove an existing `xml-collection` element and its children if it exists.

#### Properties for opennms\_xml\_collection

| Name         | Name? | Type    | Allowed Values                                          |
| ------------ | ----- | ------- | ------------------------------------------------------- |
| `collection` |   ✓   | String  |                                                         |
| `rrd_step`   |       | Integer |                                                         |
| `rras`       |       | Array   | an array of strings that match regular expression below |

`rrd_step` will default to 300 on `:create` when not specified.

`rras` will default to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create` when not specified. The regular expression it must match is `RRA:(AVERAGE\|MIN\|MAX\|LAST):.*`.

#### Examples for opennms\_xml\_collection

The following resource:

```ruby
opennms_xml_collection 'foo' do
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
end
```

results in the addition of the following element:

```xml
<xml-collection name="foo">
        <rrd step="600">
            <rra>RRA:AVERAGE:0.5:2:4032</rra>
            <rra>RRA:AVERAGE:0.5:24:2976</rra>
            <rra>RRA:AVERAGE:0.5:576:732</rra>
            <rra>RRA:MAX:0.5:576:732</rra>
            <rra>RRA:MIN:0.5:576:732</rra>
        </rrd>
</xml-collection>
```

See [xml\_collection.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_collection.rb) for additional examples.

### opennms\_xml\_source

Manages the `xml-source` child of the `xml-collection` element with name `collection_name` in `$OPENNMS_HOME/etc/xml-datacollection-config.xml`.

#### Actions for opennms\_xml\_source

* `:create` - Default. Adds the element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `xml-source` element and its children. Raises an error if the `xml-source` does not exist.
* `:delete` - Deletes the referenced `xml-source` element and its children if it exists.

#### Properties for opennms\_xml\_source

| Name                   | Name? | Type             | Identity? | Desired State? | Validation? |
| ---------------------- | ----- | ---------------- | --------- | -------------- | ----------- |
| `url`                  |   ✓   | String           |     ✓     |       ✓        |             |
| `collection_name`      |       | String           |     ✓     |       ✓        |             |
| `request_method`       |       | String           |           |       ✓        |             |
| `request_params`       |       | Hash             |           |       ✓        |             |
| `request_headers`      |       | Hash             |           |       ✓        |             |
| `request_content`      |       | String           |           |       ✓        |             |
| `request_content_type` |       | String           |           |       ✓        |             |
| `import_groups`        |       | `Array`, `false` |           |       ✓        |      ✓      |
| `import_groups_source` |       | String           |           |                |             |
| `groups`               |       | `Array`, `false` |           |       ✓        |      ✓      |

The `collection_name` must reference an existing collection (see the `xml_collection` resource above)
The `xml-datacollection-config.xml` file can be modularized by storing `xml-group` elements in separate files in `$OPENNMS_HOME/etc/xml-datacollection/` and referencing them in a source by filename with `import-group` elements.
Alternatively, the `xml-group` elements can be included directly in the `xml-source`.
This cookbook supports either method.
To reference groups in a file, use the `import_groups` property of this resource (array of file names relative to `$OPENNMS_HOME/etc/xml-datacollection`).
To add groups directly to an `xml-source` in the main file, use the `groups` property of this resource or use the `opennms_xml_group` resource (without using the `file` property).

Property `request_content_type` will default to `application/x-www-form-urlencoded` if `request_content` is specified but the former is not.

`import_groups_source` defaults to `cookbook_file`, meaning that a `cookbook_file` resource will be declared for each item in `import_group`. The path will be `$OPENNMS_HOME/etc/xml-datacollection/<import group item>` and source of `<import group item>`. If you are managing this file yourself, set this property to `external`. To source the files with `remote_file` resources instead, set this to the root directory of a URI that `remote_file` supports and that contains all files referenced by `import_groups`.

The validation performed on `import_groups` is to assert that each item in the array is a String, or `false`. When `false`, any existing `import-group` elements are removed.

The validation performed on `groups` is to assert that it is an array of hashes where each hash must contain keys `name`, `resource_type`, and `resource_xpath` (all strings); can contain `key_xpath`, `timestamp_xpath`, and `timestamp_format` (all strings), a key named `resource_keys` that if present its value must be an array of strings, and `objects` which if present must be an array of hashes with keys `name`, `type`, and `xpath` with string values. See examples for further illustration on how to use this property.

#### Examples for opennms\_xml\_source

See [xml\_source.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_source.rb) and [xml\_source\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_source_delete.rb).

### opennms\_xml\_group

Manage an `xml-group` element and its children in either an `xml-source` element of `$OPENNMS_HOME/etc/xml-datacollection-config.xml` or a tribuary file in `$OPENNMS_HOME/etc/xml-datacollection/`.

#### Actions for opennms\_xml\_group

* `:create` - Default. Adds the element with attributes and children according to the defined properties of the resource.
* `:update` - Update an existing `xml-group` element and its children. Raises an error if the `xml-group` does not exist.
* `:delete` - Deletes the referenced `xml-group` element and its children if it exists.

#### Properties for opennms\_xml\_group

| Name               | Name? | Type            | Identity? | Required? | Desired State? | Validation? | Default |
| ------------------ | ----- | --------------- | --------- | --------- | -------------- | ----------- | ------- |
| `group_name`       |   ✓   | String          |     ✓     |           |       ✓        |             |         |
| `source_url`       |       | String          |     ✓     |           |       ✓        |             |         |
| `collection_name`  |       | String          |     ✓     |           |       ✓        |             |         |
| `file`             |       | String          |     ✓     |           |       ✓        |             |         |
| `resource_type`    |       | String          |           |           |       ✓        |             | `node`  |
| `resource_xpath`   |       | String          |           |     ✓     |       ✓        |             |         |
| `key_xpath`        |       | String          |           |           |       ✓        |             |         |
| `timestamp_xpath`  |       | String          |           |           |       ✓        |             |         |
| `timestamp_format` |       | String          |           |           |       ✓        |             |         |
| `resource_keys`    |       | Array           |           |           |       ✓        |      ✓      |         |
| `objects`          |       | `Array`, `Hash` |           |           |       ✓        |      ✓      |         |

When the `file` property is set, the group is added to a file in `$OPENNMS_HOME/etc/xml-datacollection/<file>` and the `source_url` and `collection_name` properties are ignored.

The validation on `resource_keys` verifies that each item in the array is a `String`.

The validation on `objects` ensures that when the property value is an `Array`, each item is a `Hash` that contains keys `name`, `type`, and `xpath` each with `String` values. When the property value is a `Hash`, each key has a `Hash` value that contains keys `type` and `xpath` with `String` values.

#### Examples for opennms\_xml\_group

See [xml\_group.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_group.rb) and [xml\_group\_delete.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/xml_group_delete.rb).

## Thresholding

### opennms\_threshd\_package

Manages a `package` in `threshd-configuration.xml`.

#### Actions for opennms\_threshd\_package

* `:create` - Default. Adds or updates a `package` element in the file with the name matching the `package_name` property.
* `:create_if_Missing` - Adds or updates a `package` element in the file with the name matching the `package_name` property.
* `:update` - Modify an existing `package` element. Raises an error if the package does not exist.
* `:delete` - Remove an existing `package` element and its children if it exists.

#### Properties for opennms\_threshd\_package

| Name                 | Name? | Type                  | Allowed Values                                                                    |
| -------------------- | ----- | --------------------- | --------------------------------------------------------------------------------- |
| `package_name`       |   ✓   | String                |                                                                                   |
| `filter`             |       | String                |                                                                                   |
| `specifics`          |       | Array                 | array of Strings                                                                  |
| `include_ranges`     |       | Array                 | array of Strings                                                                  |
| `exclude_ranges`     |       | Array                 | array of Strings                                                                  |
| `include_urls`       |       | Array                 | array of Strings                                                                  |
| `outage_calendars`   |       | Array                 | array of Strings                                                                  |
| `services`           |       | Array                 | see below for format                                                              |

`services` should be an array of hashes with keys `name` (String, required), `interval` (Fixnum, required), `status` (`on` or `off`, required), `params` (Hash of Strings, optional).

#### Examples for opennms\_threshd\_package

See [threshold\_package.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/threshold_package.rb).

### opennms\_threshd\_service

Manages a `service` in a `package` in `threshd-configuration.xml`.

#### Actions for opennms\_threshd\_service

* `:create` - Default. Adds or updates a `service` element in the file with the name matching the `service_name` property. Requires `package_name` to exist already.
* `:update` - Modify an existing `service` element. Raises an error if the package does not exist.
* `:delete` - Remove an existing `service` element and its children if it exists.

#### Properties for opennms\_threshd\_service

| Name                   | Name? | Type                | Validation / Usage Notes                                     |
| ---------------------- | ----- | ------------------- | ------------------------------------------------------------ |
| `service_name`         |   ✓   | String              |                                                              |
| `package_name`         |       | String              | defaults to `example1`; part of identity                     |
| `interval`             |       | Integer             | defaults to `300000` for action `:create`                    |
| `user_defined`         |       | true, false         | `true` or `false`; defaults to `false` for action `:create`  |
| `status`               |       | String              | `on` or `off`; defaults to `on` for action `:create`         |
| `parameters`           |       | Hash                | should be a hash with key/value pairs that are both strings  |

#### Examples for opennms\_threshd\_service

See [threshold\_service.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/threshold_service.rb).
