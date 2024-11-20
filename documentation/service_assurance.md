# Service Assurance Resources

Service assurance, or pollers, in OpenNMS can be configured with custom resources that manage the `poller-configuration.xml` file.

## Packages and Services

### opennms\_poller\_package

Manages a `package` in `poller-configuration.xml`.

#### Actions for opennms\_poller\_package

* `:create` - Default. Adds or updates a `package` element in the file with the name matching the `package_name` property.
* `:update` - Modify an existing `package` element. Raises an error if the package does not exist.
* `:delete` - Remove an existing `package` element and its children if it exists.

#### Properties for opennms\_poller\_package

| Name                 | Name? | Type                  | Allowed Values                                                                    |
| -------------------- | ----- | --------------------- | --------------------------------------------------------------------------------- |
| `package_name`       |   ✓   | String                |                                                                                   |
| `filter`             |       | String                |                                                                                   |
| `specifics`          |       | Array                 | array of Strings                                                                  |
| `include_ranges`     |       | Array                 | array of Strings                                                                  |
| `exclude_ranges`     |       | Array                 | array of Strings                                                                  |
| `include_urls`       |       | Array                 | array of Strings                                                                  |
| `outage_calendars`   |       | Array                 | array of Strings                                                                  |
| `remote`             |       | [true, false]         |                                                                                   |
| `rrd_step`           |       | Integer               | Defaults to 300 on `:create`                                                      |
| `rras`               |       | Array                 | array of valid RRA strings                                                        |

`rras` defaults to `['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']` on `:create`.

#### Examples for opennms\_poller\_package

Recipe [poller.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller.rb) contains several varying examples of package creation.
Recipe [poller\_edit.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller_edit.rb) contains examples of editing packages.
Recipe [poller\_delete.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller_delete.rb) contains an example of deleting packages.

### opennms\_poller\_service

Manages a `service` in a `package` in `poller-configuration.xml`.

#### Actions for opennms\_poller\_service

* `:create` - Default. Adds or updates a `service` element to the package named `package_name` in the file with the name matching the `service_name` property.
* `:update` - Modify an existing `service` element. Raises an error if the package or service does not exist.
* `:delete` - Remove an existing `service` element and its children if it exists.

#### Properties for opennms\_poller\_service

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
| `parameters`           |       | Hash                | see below                                                    |
| `class_parameters`     |       | Hash                | see below                                                    |
| `pattern`              |       | String              |                                                              |

`parameters` and `class_parameters` are both to be hashes with string keys and hash values that include a key named `value` with a string value and an optional key `configuration` that is a complete and valid single XML element and its children.

#### Examples for opennms\_poller\_service

Recipe [poller.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller.rb) contains several varying examples of poller service creation.
Recipe [poller\_edit.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller_edit.rb) contains examples of editing services.
Recipe [poller\_delete.rb](../test/fixtures/cookbooks/openms_resource_tests/recipes/poller_delete.rb) contains an example of deleting services.
