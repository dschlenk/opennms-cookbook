# Statistics Daemon Resources

The configuration of the statistics daemon feature of OpenNMS can be managed using the `opennms_statsd_package` and `opennms_statsd_report` resources.

## opennms\_statsd\_package

Manages a `package` element in the configuration file, optionally with a `filter` child element.

### Actions for opennms\_statsd\_package

* `:create` - Default. Creates a new `package` element and optionally `filter` child element if it does not exist. Will update if already exists.
* `:create_if_missing` - Creates a new `package` element if it does not exist and optional `filter` child element. Will not update an existing `package` with the same `package_name`.
* `:update` - Updates the `filter` element of an existing `package` if the `:filter` property does not match the current value. Raises an error if the `package` does not already exist.
* `:delete` - Deletes an existing `package` and its children if it exists.

### Properties for opennms\_statsd\_package

| Name | Name? | Type | Required? |
| ---- | ----- | ---- | ---------------------- |
| `package_name` | x | String | |
| `filter` | | String | |

## opennms\_statsd\_report`

Manage a report in a package. The package must exist.

### Actions for opennms\_statsd\_report

* `:create` - Default. Creates a new `packageReport` child element of the `package` element with a title matching the `package_name` property of this resource if it does not exist. Will update if already exists. Raises an error if the `package` element does not exist.
* `:create_if_missing` - Creates a new `packageReport` child element of the `package` element with a title matching the `package_name` property of this resource if it does not exist. Will not update an existing statsd\_report with the same `report_name`.
* `:update` - Updates an existing `statsd_report` child element of the `package` element with a title matching the `package_name` property of this resource. Raises an error if the `package` does not exist.
* `:delete` - Deletes an existing `packageReport` with name `report_name` from `package` with name `package_name` if it exists.

### Properties for opennms\_statsd\_report

| Name | Name? | Type | Required? | Notes |
| ---- | ----- | ---- | --------- | ----- |
| `report_name` | x | String | | |
| `package_name` | | String | x | Part of identity |
| `description` | | String | | Required when new |
| `schedule` | | String | | Defaults to daily at 01:20:00 when new |
| `retain_interval` | | Integer | | Defaults to 30 days when new |
| `status` | | String | | Defaults to `on` when new. Can be `on` or `off`. |
| `parameters` | | Hash | | Must be a Hash with String keys and String values |
| `class_name` | | String | | Defaults to 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor' when new. Can be that or 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor' |

### Examples for opennms\_statsd\_package and opennms\_statsd\_report

Recipe [statsd.rb](../test/fixtures/cookbooks/opennms_resource_tests/recipes/statsd.rb) demonstrates use.
